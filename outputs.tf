# VM Outputs - Multi-VM Support with Backward Compatibility

# Multi-VM Outputs (Primary approach)
output "vms" {
  description = "Map of all created VMs with their details"
  value = {
    for k, v in proxmox_vm_qemu.vm : k => {
      id          = v.vmid
      name        = v.name
      node        = v.target_node
      ip_address  = v.default_ipv4_address
      mac_address = try(v.network[0].macaddr, "")
      cpu_cores   = v.cores
      memory      = v.memory
      disk_size   = try(v.disk[0].size, "")
      status      = v.agent == 1 ? "Agent enabled" : "Agent disabled"
      ssh_command = length(regexall("^$", try(local.final_vm_configs[k].ci_user, ""))) == 0 ? "ssh ${local.final_vm_configs[k].ci_user}@${v.default_ipv4_address}" : "SSH user not configured"
    }
  }
}

# Individual VM Access (for easier scripting)
output "vm_details" {
  description = "Individual VM details by key"
  value = {
    for k, v in proxmox_vm_qemu.vm : k => {
      id         = v.vmid
      name       = v.name
      node       = v.target_node
      ip_address = v.default_ipv4_address
    }
  }
}

# Summary Outputs
output "vm_count" {
  description = "Total number of VMs created"
  value       = length(proxmox_vm_qemu.vm)
}

output "vm_names" {
  description = "List of all VM names"
  value       = [for v in proxmox_vm_qemu.vm : v.name]
}

output "vm_ip_addresses" {
  description = "Map of VM names to IP addresses"
  value       = { for k, v in proxmox_vm_qemu.vm : v.name => v.default_ipv4_address }
}

output "vm_nodes" {
  description = "Map of VM names to their Proxmox nodes"
  value       = { for k, v in proxmox_vm_qemu.vm : v.name => v.target_node }
}

# SSH Connection Commands
output "ssh_commands" {
  description = "SSH connection commands for all VMs"
  value = {
    for k, v in proxmox_vm_qemu.vm : v.name =>
    length(regexall("^$", try(local.final_vm_configs[k].ci_user, ""))) == 0 ?
    "ssh ${local.final_vm_configs[k].ci_user}@${v.default_ipv4_address}" :
    "SSH user not configured"
  }
}

# Legacy Outputs (for backward compatibility)
# These will work when only one VM is created or when using legacy variables
output "vm_id" {
  description = "[LEGACY] ID of the first/only VM (use 'vms' output for multi-VM)"
  value       = length(proxmox_vm_qemu.vm) > 0 ? values(proxmox_vm_qemu.vm)[0].vmid : null
}

output "vm_name" {
  description = "[LEGACY] Name of the first/only VM (use 'vms' output for multi-VM)"
  value       = length(proxmox_vm_qemu.vm) > 0 ? values(proxmox_vm_qemu.vm)[0].name : null
}

output "vm_node" {
  description = "[LEGACY] Proxmox node of the first/only VM (use 'vms' output for multi-VM)"
  value       = length(proxmox_vm_qemu.vm) > 0 ? values(proxmox_vm_qemu.vm)[0].target_node : null
}

output "vm_ip_address" {
  description = "[LEGACY] IP address of the first/only VM (use 'vms' output for multi-VM)"
  value       = length(proxmox_vm_qemu.vm) > 0 ? values(proxmox_vm_qemu.vm)[0].default_ipv4_address : null
}

output "vm_mac_address" {
  description = "[LEGACY] MAC address of the first/only VM (use 'vms' output for multi-VM)"
  value       = length(proxmox_vm_qemu.vm) > 0 ? try(values(proxmox_vm_qemu.vm)[0].network[0].macaddr, "") : null
}

output "vm_cpu_cores" {
  description = "[LEGACY] CPU cores of the first/only VM (use 'vms' output for multi-VM)"
  value       = length(proxmox_vm_qemu.vm) > 0 ? values(proxmox_vm_qemu.vm)[0].cores : null
}

output "vm_memory" {
  description = "[LEGACY] Memory of the first/only VM (use 'vms' output for multi-VM)"
  value       = length(proxmox_vm_qemu.vm) > 0 ? values(proxmox_vm_qemu.vm)[0].memory : null
}

output "vm_disk_size" {
  description = "[LEGACY] Disk size of the first/only VM (use 'vms' output for multi-VM)"
  value       = length(proxmox_vm_qemu.vm) > 0 ? try(values(proxmox_vm_qemu.vm)[0].disk[0].size, "") : null
}

output "vm_status" {
  description = "[LEGACY] Status of the first/only VM (use 'vms' output for multi-VM)"
  value       = length(proxmox_vm_qemu.vm) > 0 ? (values(proxmox_vm_qemu.vm)[0].agent == 1 ? "Agent enabled" : "Agent disabled") : null
}

output "vm_ssh_connection_command" {
  description = "[LEGACY] SSH command for the first/only VM (use 'ssh_commands' output for multi-VM)"
  value = length(proxmox_vm_qemu.vm) > 0 ? (
    length(regexall("^$", try(values(local.final_vm_configs)[0].ci_user, ""))) == 0 ?
    "ssh ${values(local.final_vm_configs)[0].ci_user}@${values(proxmox_vm_qemu.vm)[0].default_ipv4_address}" :
    "SSH user not configured"
  ) : null
}