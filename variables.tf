# Proxmox Connection Variables
variable "proxmox_api_url" {
  description = "Proxmox API URL"
  type        = string
}

variable "proxmox_api_token_id" {
  description = "Proxmox API token ID (e.g., 'terraform@pve!terraform')"
  type        = string
}

variable "proxmox_api_token_secret" {
  description = "Proxmox API token secret"
  type        = string
  sensitive   = true
}

variable "proxmox_tls_insecure" {
  description = "Allow insecure TLS connections"
  type        = bool
  default     = true
}

variable "proxmox_parallel" {
  description = "Number of parallel operations"
  type        = number
  default     = 1
}

variable "proxmox_timeout" {
  description = "Timeout for operations in seconds"
  type        = number
  default     = 300
}

# VM Configuration Variables
variable "vms" {
  description = "Map of VMs to create with their specific configurations"
  type = map(object({
    name          = string
    description   = optional(string, "VM created with Terraform")
    target_node   = string
    template_name = string
    vmid          = optional(number, null)

    # CPU Configuration
    cpu_cores   = optional(number, 2)
    cpu_sockets = optional(number, 1)
    cpu_type    = optional(string, "host")

    # Memory Configuration
    memory  = optional(number, 2048)
    balloon = optional(number, 0)

    # Storage Configuration
    disk_size     = optional(string, "20G")
    disk_type     = optional(string, "scsi")
    disk_storage  = optional(string, "local-lvm")
    disk_format   = optional(string, "raw")
    disk_cache    = optional(string, "none")
    disk_iothread = optional(bool, true)

    # Network Configuration
    network_model    = optional(string, "virtio")
    network_bridge   = optional(string, "vmbr0")
    network_tag      = optional(number, null)
    network_firewall = optional(bool, false)

    # OS Configuration
    os_type = optional(string, "cloud-init")
    qemu_os = optional(string, "l26")

    # Cloud-Init Configuration
    cloudinit_cdrom_storage = optional(string, "local-lvm")
    ci_user                 = optional(string, "ubuntu")
    ci_password             = optional(string, "")
    ci_ssh_keys             = optional(list(string), [])
    ci_ssh_private_key      = optional(string, "")
    ipconfig0               = optional(string, "dhcp")
    nameserver              = optional(string, "8.8.8.8")
    searchdomain            = optional(string, "local")

    # Additional Configuration
    onboot     = optional(bool, true)
    startup    = optional(string, "")
    protection = optional(bool, false)
    hotplug    = optional(string, "network,disk,usb")
    agent      = optional(number, 1)
    tags       = optional(string, "")
  }))
  default = {}
}

# Global defaults for backward compatibility and shared settings
variable "global_defaults" {
  description = "Global default values that apply to all VMs unless overridden"
  type = object({
    target_node             = optional(string, "")
    template_name           = optional(string, "")
    cpu_cores               = optional(number, 2)
    cpu_sockets             = optional(number, 1)
    cpu_type                = optional(string, "host")
    memory                  = optional(number, 2048)
    balloon                 = optional(number, 0)
    disk_size               = optional(string, "20G")
    disk_type               = optional(string, "scsi")
    disk_storage            = optional(string, "local-lvm")
    disk_format             = optional(string, "raw")
    disk_cache              = optional(string, "none")
    disk_iothread           = optional(bool, true)
    network_model           = optional(string, "virtio")
    network_bridge          = optional(string, "vmbr0")
    network_tag             = optional(number, null)
    network_firewall        = optional(bool, false)
    os_type                 = optional(string, "cloud-init")
    qemu_os                 = optional(string, "l26")
    cloudinit_cdrom_storage = optional(string, "local-lvm")
    ci_user                 = optional(string, "ubuntu")
    ci_password             = optional(string, "")
    ci_ssh_keys             = optional(list(string), [])
    ci_ssh_private_key      = optional(string, "")
    ipconfig0               = optional(string, "dhcp")
    nameserver              = optional(string, "8.8.8.8")
    searchdomain            = optional(string, "local")
    onboot                  = optional(bool, true)
    startup                 = optional(string, "")
    protection              = optional(bool, false)
    hotplug                 = optional(string, "network,disk,usb")
    agent                   = optional(number, 1)
    tags                    = optional(string, "")
  })
  default = {}
}

# Legacy Variables (maintained for backward compatibility)
# These will be used as fallbacks when not specified in vm configuration or global_defaults
variable "vm_name" {
  description = "[DEPRECATED] Use 'vms' variable instead. Name of the virtual machine"
  type        = string
  default     = null
}

variable "vm_description" {
  description = "[DEPRECATED] Use 'vms' variable instead. Description of the virtual machine"
  type        = string
  default     = "VM created with Terraform"
}

variable "target_node" {
  description = "[DEPRECATED] Use 'global_defaults' instead. Proxmox node name where VM will be created"
  type        = string
  default     = null
}

variable "template_name" {
  description = "[DEPRECATED] Use 'global_defaults' instead. Name of the template to clone"
  type        = string
  default     = null
}