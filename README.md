# Terraform Proxmox VM

[![Terraform](https://img.shields.io/badge/Terraform-%3E%3D1.0-blue.svg)](https://www.terraform.io/)
[![Provider](https://img.shields.io/badge/Provider-telmate%2Fproxmox-orange.svg)](https://registry.terraform.io/providers/telmate/proxmox/latest)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

A flexible and scalable Terraform configuration for deploying virtual machines on Proxmox VE hypervisor. Supports both single VM and multi-VM deployments with comprehensive configuration options.

## ✨ Features

- **🚀 Scalable Architecture**: Deploy 1 to N VMs with a single configuration
- **🔧 Flexible Configuration**: Per-VM customization with global defaults
- **🔒 Secure by Default**: API token authentication and sensitive variable handling
- **🌐 Multi-Node Support**: Distribute VMs across different Proxmox nodes
- **📦 Template Flexibility**: Use different templates for different VM types
- **🔄 Backward Compatible**: Supports legacy single-VM configurations
- **☁️ Cloud-Init Ready**: Automated initial configuration and SSH key deployment
- **📊 Rich Outputs**: Comprehensive VM details and ready-to-use SSH connections

## 🏗️ Architecture

The configuration uses a three-tier hierarchy for maximum flexibility:

1. **VM-specific settings** (highest priority)
2. **Global defaults** (shared across VMs)
3. **Hardcoded defaults** (fallback values)

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   VM Config     │───▶│ Global Defaults │───▶│ Hard Defaults   │
│   (Override)    │    │   (Shared)      │    │  (Fallback)     │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 📋 Prerequisites

- **Terraform** >= 1.0
- **Proxmox VE** cluster with API access
- **VM Templates** prepared in Proxmox (Ubuntu, CentOS, etc.)
- **API Token** created in Proxmox with appropriate permissions

### Proxmox API Token Setup

1. Navigate to **Datacenter → Permissions → API Tokens**
2. Create a new token: `terraform@pve!terraform`
3. Set appropriate permissions (typically PVEVMAdmin role)
4. Copy the generated token secret

## 🚀 Quick Start

### 1. Clone and Setup

```bash
git clone <repository-url>
cd terraform-proxmox-vm
cp terraform.tfvars.example terraform.tfvars
```

### 2. Configure Variables

Edit `terraform.tfvars` with your environment details:

```hcl
# Proxmox Connection
proxmox_api_url          = "https://your-proxmox:8006/api2/json"
proxmox_api_token_id     = "terraform@pve!terraform"
proxmox_api_token_secret = "your-token-secret"

# Global defaults for all VMs
global_defaults = {
  target_node   = "proxmox-node-01"
  template_name = "ubuntu-22.04-template"
  memory        = 4096
  disk_size     = "30G"
}

# Define your VMs
vms = {
  "web-01" = {
    name      = "web-server-01"
    memory    = 8192
    ipconfig0 = "ip=192.168.1.101/24,gw=192.168.1.1"
  }
}
```

### 3. Deploy

```bash
terraform init
terraform plan
terraform apply
```

## 📚 Usage Examples

### Simple Multi-VM Setup

```hcl
vms = {
  "web" = {
    name = "web-server"
    vmid = 101
    memory = 8192
    ipconfig0 = "ip=192.168.1.101/24,gw=192.168.1.1"
  }
  "db" = {
    name = "database-server"
    vmid = 102
    memory = 16384
    disk_size = "100G"
    ipconfig0 = "ip=192.168.1.102/24,gw=192.168.1.1"
  }
}
```

### Kubernetes Cluster

```hcl
vms = {
  "k8s-master" = {
    name = "k8s-master-01"
    vmid = 201
    cpu_cores = 4
    memory = 8192
    disk_size = "50G"
    ipconfig0 = "ip=192.168.2.10/24,gw=192.168.2.1"
    tags = "kubernetes,master"
  }
  "k8s-worker-1" = {
    name = "k8s-worker-01"
    vmid = 202
    cpu_cores = 4
    memory = 16384
    disk_size = "100G"
    ipconfig0 = "ip=192.168.2.11/24,gw=192.168.2.1"
    tags = "kubernetes,worker"
  }
}
```

### Development Environment

```hcl
vms = {
  "dev-frontend" = {
    name = "dev-frontend"
    template_name = "nodejs-template"
    cpu_cores = 2
    memory = 4096
    ipconfig0 = "dhcp"
    tags = "development,frontend"
  }
  "dev-backend" = {
    name = "dev-backend"
    template_name = "python-template"
    cpu_cores = 2
    memory = 4096
    ipconfig0 = "dhcp"
    tags = "development,backend"
  }
}
```

### Multi-Node with Different Templates

```hcl
vms = {
  "web-01" = {
    name = "web-server-01"
    target_node = "proxmox-node-01"
    template_name = "nginx-template"
    memory = 8192
  }
  "db-01" = {
    name = "database-01"
    target_node = "proxmox-node-02"
    template_name = "postgres-template"
    memory = 16384
    disk_storage = "fast-ssd"
  }
}
```

## 🔧 Configuration Options

### VM Configuration

Each VM in the `vms` map supports these options:

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `name` | string | - | VM hostname |
| `description` | string | "VM created with Terraform" | VM description |
| `target_node` | string | - | Proxmox node name |
| `template_name` | string | - | Template to clone |
| `vmid` | number | null | VM ID (auto-assigned if null) |
| `cpu_cores` | number | 2 | Number of CPU cores |
| `cpu_sockets` | number | 1 | Number of CPU sockets |
| `memory` | number | 2048 | Memory in MB |
| `disk_size` | string | "20G" | Disk size |
| `disk_storage` | string | "local-lvm" | Storage pool |
| `network_bridge` | string | "vmbr0" | Network bridge |
| `ipconfig0` | string | "dhcp" | IP configuration |
| `ci_ssh_keys` | list(string) | [] | SSH public keys |
| `tags` | string | "" | VM tags |

See `terraform.tfvars.example` for complete configuration options.

### Global Defaults

Use `global_defaults` to set common values across all VMs:

```hcl
global_defaults = {
  target_node = "proxmox-node-01"
  template_name = "ubuntu-22.04-template"
  memory = 4096
  ci_ssh_keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC... your-key"
  ]
}
```

## 📤 Outputs

The configuration provides comprehensive outputs:

### Multi-VM Outputs

```bash
# Complete VM details
terraform output vms

# VM count and names
terraform output vm_count
terraform output vm_names

# IP addresses mapped by VM name
terraform output vm_ip_addresses

# Ready-to-use SSH commands
terraform output ssh_commands
```

### Example Output

```json
{
  "vms": {
    "web-01": {
      "id": 101,
      "name": "web-server-01",
      "ip_address": "192.168.1.101",
      "ssh_command": "ssh ubuntu@192.168.1.101"
    }
  }
}
```

## 🔒 Security Best Practices

### Authentication

- ✅ Use API tokens instead of username/password
- ✅ Set `proxmox_tls_insecure = false` for production
- ✅ Use SSH keys instead of passwords

### Network Security

- Configure appropriate firewall rules per VM
- Use VLANs for network segmentation
- Implement proper access controls

### Data Protection

- Enable VM protection for critical workloads
- Use encrypted storage pools
- Regular backup strategies

## 🐛 Troubleshooting

### Common Issues

**1. Provider Not Found**
```bash
# Solution: Initialize Terraform
terraform init
```

**2. Template Not Found**
```bash
# Verify template exists in Proxmox
# Check template name spelling in configuration
```

**3. Authentication Failed**
```bash
# Verify API token has correct permissions
# Check token ID format: user@realm!token-name
```

**4. IP Configuration Issues**
```bash
# Ensure DHCP is available or use static IP
# Verify network bridge exists
```

### Debugging

```bash
# Validate configuration
terraform validate

# Test configuration merging
terraform console
> local.final_vm_configs

# Check planned changes
terraform plan
```

## 🔄 Migration Guide

### From Legacy Single-VM

1. **Keep existing config** - Legacy variables still work
2. **Gradual migration**:
   ```hcl
   # Step 1: Add global defaults
   global_defaults = {
     target_node = var.target_node
     template_name = var.template_name
   }
   
   # Step 2: Convert to vms map
   vms = {
     "legacy-vm" = {
       name = var.vm_name
       # other settings...
     }
   }
   
   # Step 3: Remove legacy variables
   ```

3. **Update output references** from legacy to new output names

## 🤝 Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

### Development Setup

1. Clone the repository
2. Install required tools (Terraform, pre-commit hooks)
3. Make changes and test thoroughly
4. Submit pull request with clear description

### Reporting Issues

- Use GitHub issues for bug reports
- Include Terraform version and provider versions
- Provide minimal reproduction steps

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [Telmate Proxmox Provider](https://registry.terraform.io/providers/telmate/proxmox) for Terraform integration
- Proxmox VE community for the excellent virtualization platform
- HashiCorp for Terraform

---

**Need help?** Check the [troubleshooting section](#-troubleshooting) or open an issue.