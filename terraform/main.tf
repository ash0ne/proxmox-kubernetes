terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "2.9.14"
    }
  }
}

# Init provider
provider "proxmox" {
  pm_api_url          = var.server_url
  pm_api_token_id     = var.token_id
  pm_api_token_secret = var.token_secret
  pm_tls_insecure     = true
}

# Create VM for main k8s node
resource "proxmox_vm_qemu" "kube-server" {
  count       = 1
  name        = "kube-server-0${count.index + 1}"
  target_node = var.target_node_main
  vmid        = "70${count.index + 1}"
  qemu_os     = "other"
  clone       = var.vm_template_name
  agent       = 1
  os_type     = "cloud-init"
  cores       = 2
  sockets     = 1
  cpu         = "host"
  memory      = 4096
  scsihw      = "virtio-scsi-pci"
  bootdisk    = "scsi0"

  disk {
    slot     = 0
    size     = "32G"
    type     = "scsi"
    storage  = var.file_system == "zfs" ? "local-zfs" : "local-lvm"
    iothread = 0
  }

  network {
    model  = "virtio"
    bridge = "vmbr0"
  }

  lifecycle {
    ignore_changes = [
      network,
    ]
  }

  ipconfig0 = "ip=${var.ip_net_main},gw=${var.gateway}"

  sshkeys = <<EOF
  ${var.ssh_key}
  EOF
}

locals {
  ip_parts     = split(".", var.ip_net_agent)
  ip_last_byte = split("/", local.ip_parts[3])[0]
}

# Create VMs for agent k8s nodes
resource "proxmox_vm_qemu" "kube-agent" {
  count       = 2
  name        = "kube-agent-0${count.index + 1}"
  target_node = var.target_node_agent
  vmid        = "80${count.index + 1}"
  qemu_os     = "other"
  clone       = var.vm_template_name
  agent       = 1
  os_type     = "cloud-init"
  cores       = 1
  sockets     = 1
  cpu         = "host"
  memory      = 3072
  scsihw      = "virtio-scsi-pci"
  bootdisk    = "scsi0"

  disk {
    slot     = 0
    size     = "16G"
    type     = "scsi"
    storage  = var.file_system == "zfs" ? "local-zfs" : "local-lvm"
    iothread = 0
  }

  network {
    model  = "virtio"
    bridge = "vmbr0"
  }

  lifecycle {
    ignore_changes = [
      network,
    ]
  }

  # Create IPs in increasing order of the given agent IP
  ipconfig0 = "ip=${cidrhost(var.ip_net_agent, local.ip_last_byte + count.index)}/24,gw=${var.gateway}"


  sshkeys = <<EOF
  ${var.ssh_key}
  EOF
}
