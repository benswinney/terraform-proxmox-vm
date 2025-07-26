# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This repository contains a scalable Terraform configuration for deploying virtual machines on Proxmox VE hypervisor. The architecture has evolved from single-VM to multi-VM deployment with flexible per-VM configuration, backward compatibility, and comprehensive resource management.

## Common Commands

```bash
# Initialize Terraform (run first time or after adding new providers)
terraform init

# Validate configuration syntax (will fail until terraform init is run)
terraform validate

# Format Terraform files
terraform fmt

# Plan deployment (see what will be created/changed)
terraform plan

# Apply configuration (create/update infrastructure)
terraform apply

# Destroy infrastructure
terraform destroy

# Show current state
terraform show

# List outputs
terraform output

# Get specific output (useful for automation)
terraform output vms
terraform output vm_ip_addresses
terraform output ssh_commands
```

## Configuration Architecture

### Multi-VM Deployment System

The configuration uses a three-tier hierarchy for VM configuration:

1. **VM-specific settings** (in `vms` map) - highest priority
2. **Global defaults** (in `global_defaults` object) - shared settings
3. **Hardcoded defaults** - fallback values

### Core Components

- **main.tf**: Uses `for_each` with `proxmox_vm_qemu` resource for scalable VM deployment
- **variables.tf**: Complex object types supporting both multi-VM and legacy single-VM configurations
- **provider.tf**: API token-based authentication (migrated from username/password)
- **outputs.tf**: Multi-VM aware outputs with backward compatibility for legacy single-VM outputs

### Configuration Merging Logic

The `locals` block in `main.tf` implements sophisticated configuration merging:
- `vm_configs`: Processes the `vms` variable with `coalesce()` functions for fallback values
- `legacy_vm_config`: Backward compatibility for single-VM deployments using legacy variables
- `final_vm_configs`: Combines both approaches using `merge()`

## Configuration Setup

### Multi-VM Approach (Recommended)

1. Copy and customize the example:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. Configure global defaults and individual VMs:
   ```hcl
   global_defaults = {
     target_node = "proxmox-node-01"
     template_name = "ubuntu-22.04-template"
     # ... other shared settings
   }
   
   vms = {
     "web-01" = {
       name = "web-server-01"
       memory = 8192
       # VM-specific overrides
     }
     "db-01" = {
       name = "database-01"
       template_name = "postgres-template"  # Different template
       target_node = "proxmox-node-02"     # Different node
     }
   }
   ```

### Legacy Single-VM Support

The configuration maintains backward compatibility:
- Legacy variables (`vm_name`, `target_node`, etc.) still work
- Automatically creates single VM if `vms` is empty but legacy variables are set
- Legacy outputs preserved with `[LEGACY]` markers

## Key Architecture Patterns

### Scalable Resource Creation
- Uses `for_each = local.final_vm_configs` for dynamic VM creation
- Each VM key becomes the resource instance key
- Supports 1 to N VMs in single configuration

### Configuration Flexibility
- **Per-VM templates**: Different VMs can use different Proxmox templates
- **Multi-node deployment**: VMs can be distributed across Proxmox nodes
- **Individual networking**: Separate IP configs, VLANs, bridges per VM
- **Resource scaling**: CPU, memory, disk customized per VM

### Output Structure
- **Primary outputs**: `vms` (complete VM details), `vm_details` (simplified)
- **Summary outputs**: `vm_count`, `vm_names`, `vm_ip_addresses`
- **Utility outputs**: `ssh_commands` for ready-to-use SSH connections
- **Legacy outputs**: Maintain compatibility for single-VM deployments

## Security Implementation

### Authentication
- **API Token Authentication**: Uses `pm_api_token_id` and `pm_api_token_secret`
- **Sensitive Variables**: API token secret, cloud-init passwords, SSH private keys marked `sensitive = true`
- **TLS Configuration**: `proxmox_tls_insecure` defaults to `true` (should be `false` for production)

### Access Control
- **Protection Flag**: Prevents accidental VM destruction when enabled
- **SSH Key Management**: Supports multiple SSH keys per VM with fallback to global defaults
- **Network Security**: Firewall settings configurable per VM

## Development Patterns

### Making Changes to VM Configuration
1. Always test with `terraform plan` first
2. Consider impact on existing VMs (some changes require recreation)
3. Use lifecycle rules carefully - network changes are ignored by default

### Adding New VM Types
1. Create new entry in `vms` map with unique key
2. Override necessary settings from global defaults
3. Specify different templates/nodes as needed

### Debugging Configuration Issues
- Use `terraform console` to test local value calculations
- Check `local.final_vm_configs` to see merged configuration
- Validate template and node names exist in Proxmox before applying

### Migration from Legacy to Multi-VM
1. Convert single VM config to `vms` map entry
2. Move common settings to `global_defaults`
3. Update output references from legacy to new output names
4. Test with `terraform plan` to ensure no resource recreation