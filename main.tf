# Local values for configuration merging
locals {
  # Create merged configuration for each VM
  vm_configs = {
    for vm_key, vm_config in var.vms : vm_key => {
      # Basic VM Configuration
      name          = vm_config.name
      description   = vm_config.description
      target_node   = coalesce(vm_config.target_node, var.global_defaults.target_node, var.target_node)
      template_name = coalesce(vm_config.template_name, var.global_defaults.template_name, var.template_name)
      vmid          = vm_config.vmid

      # CPU Configuration
      cpu_cores   = coalesce(vm_config.cpu_cores, var.global_defaults.cpu_cores, 2)
      cpu_sockets = coalesce(vm_config.cpu_sockets, var.global_defaults.cpu_sockets, 1)
      cpu_type    = coalesce(vm_config.cpu_type, var.global_defaults.cpu_type, "host")

      # Memory Configuration
      memory  = coalesce(vm_config.memory, var.global_defaults.memory, 2048)
      balloon = coalesce(vm_config.balloon, var.global_defaults.balloon, 0)

      # Storage Configuration
      disk_size     = coalesce(vm_config.disk_size, var.global_defaults.disk_size, "20G")
      disk_type     = coalesce(vm_config.disk_type, var.global_defaults.disk_type, "scsi")
      disk_storage  = coalesce(vm_config.disk_storage, var.global_defaults.disk_storage, "local-lvm")
      disk_format   = coalesce(vm_config.disk_format, var.global_defaults.disk_format, "raw")
      disk_cache    = coalesce(vm_config.disk_cache, var.global_defaults.disk_cache, "none")
      disk_iothread = coalesce(vm_config.disk_iothread, var.global_defaults.disk_iothread, true)

      # Network Configuration
      network_model    = coalesce(vm_config.network_model, var.global_defaults.network_model, "virtio")
      network_bridge   = coalesce(vm_config.network_bridge, var.global_defaults.network_bridge, "vmbr0")
      network_tag      = coalesce(vm_config.network_tag, var.global_defaults.network_tag)
      network_firewall = coalesce(vm_config.network_firewall, var.global_defaults.network_firewall, false)

      # OS Configuration
      os_type = coalesce(vm_config.os_type, var.global_defaults.os_type, "cloud-init")
      qemu_os = coalesce(vm_config.qemu_os, var.global_defaults.qemu_os, "l26")

      # Cloud-Init Configuration
      cloudinit_cdrom_storage = coalesce(vm_config.cloudinit_cdrom_storage, var.global_defaults.cloudinit_cdrom_storage, "local-lvm")
      ci_user                 = coalesce(vm_config.ci_user, var.global_defaults.ci_user, "ubuntu")
      ci_password             = coalesce(vm_config.ci_password, var.global_defaults.ci_password, "")
      ci_ssh_keys             = length(vm_config.ci_ssh_keys) > 0 ? vm_config.ci_ssh_keys : (length(var.global_defaults.ci_ssh_keys) > 0 ? var.global_defaults.ci_ssh_keys : [])
      ci_ssh_private_key      = coalesce(vm_config.ci_ssh_private_key, var.global_defaults.ci_ssh_private_key, "")
      ipconfig0               = coalesce(vm_config.ipconfig0, var.global_defaults.ipconfig0, "dhcp")
      nameserver              = coalesce(vm_config.nameserver, var.global_defaults.nameserver, "8.8.8.8")
      searchdomain            = coalesce(vm_config.searchdomain, var.global_defaults.searchdomain, "local")

      # Additional Configuration
      onboot     = coalesce(vm_config.onboot, var.global_defaults.onboot, true)
      startup    = coalesce(vm_config.startup, var.global_defaults.startup, "")
      protection = coalesce(vm_config.protection, var.global_defaults.protection, false)
      hotplug    = coalesce(vm_config.hotplug, var.global_defaults.hotplug, "network,disk,usb")
      agent      = coalesce(vm_config.agent, var.global_defaults.agent, 1)
      tags       = coalesce(vm_config.tags, var.global_defaults.tags, "")
    }
  }

  # Backward compatibility: if no VMs defined but legacy variables exist, create a single VM
  legacy_vm_config = var.vm_name != null && length(var.vms) == 0 ? {
    "legacy-vm" = {
      name                    = var.vm_name
      description             = var.vm_description
      target_node             = var.target_node
      template_name           = var.template_name
      vmid                    = null
      cpu_cores               = 2
      cpu_sockets             = 1
      cpu_type                = "host"
      memory                  = 2048
      balloon                 = 0
      disk_size               = "20G"
      disk_type               = "scsi"
      disk_storage            = "local-lvm"
      disk_format             = "raw"
      disk_cache              = "none"
      disk_iothread           = true
      network_model           = "virtio"
      network_bridge          = "vmbr0"
      network_tag             = null
      network_firewall        = false
      os_type                 = "cloud-init"
      qemu_os                 = "l26"
      cloudinit_cdrom_storage = "local-lvm"
      ci_user                 = "ubuntu"
      ci_password             = ""
      ci_ssh_keys             = []
      ci_ssh_private_key      = ""
      ipconfig0               = "dhcp"
      nameserver              = "8.8.8.8"
      searchdomain            = "local"
      onboot                  = true
      startup                 = ""
      protection              = false
      hotplug                 = "network,disk,usb"
      agent                   = 1
      tags                    = ""
    }
  } : {}

  # Final configuration combining new and legacy approaches
  final_vm_configs = merge(local.vm_configs, local.legacy_vm_config)
}

resource "proxmox_vm_qemu" "vm" {
  for_each = local.final_vm_configs

  # Basic VM Configuration
  name        = each.value.name
  desc        = each.value.description
  target_node = each.value.target_node
  clone       = each.value.template_name
  vmid        = each.value.vmid
  os_type     = each.value.os_type
  qemu_os     = each.value.qemu_os

  # CPU Configuration
  cores   = each.value.cpu_cores
  sockets = each.value.cpu_sockets
  cpu     = each.value.cpu_type

  # Memory Configuration
  memory  = each.value.memory
  balloon = each.value.balloon

  # Boot and Agent Configuration
  onboot     = each.value.onboot
  startup    = each.value.startup
  protection = each.value.protection
  agent      = each.value.agent
  hotplug    = each.value.hotplug

  # Tags
  tags = each.value.tags

  # Disk Configuration
  disk {
    slot     = 0
    size     = each.value.disk_size
    type     = each.value.disk_type
    storage  = each.value.disk_storage
    format   = each.value.disk_format
    cache    = each.value.disk_cache
    iothread = each.value.disk_iothread
  }

  # Network Configuration
  network {
    model    = each.value.network_model
    bridge   = each.value.network_bridge
    tag      = each.value.network_tag
    firewall = each.value.network_firewall
  }

  # Cloud-Init Configuration
  cloudinit_cdrom_storage = each.value.cloudinit_cdrom_storage

  # Cloud-Init Settings
  ciuser       = each.value.ci_user
  cipassword   = each.value.ci_password
  sshkeys      = length(each.value.ci_ssh_keys) > 0 ? join("\n", each.value.ci_ssh_keys) : ""
  ipconfig0    = each.value.ipconfig0
  nameserver   = each.value.nameserver
  searchdomain = each.value.searchdomain

  # Lifecycle Management
  lifecycle {
    ignore_changes = [
      network,
    ]
  }

  # Connection for provisioning (optional)
  dynamic "connection" {
    for_each = each.value.ci_ssh_private_key != "" ? [1] : []
    content {
      type        = "ssh"
      user        = each.value.ci_user
      private_key = each.value.ci_ssh_private_key
      host        = self.default_ipv4_address
    }
  }
}