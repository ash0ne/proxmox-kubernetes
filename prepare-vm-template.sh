#!/bin/bash

usage() {
    echo "Usage: $0 --vmid <VMID> [--storage <STORAGE>] [--help]"
    echo "Options:"
    echo "  --vmid       Specify a unique VM ID (required)."
    echo "  --storage    Specify the storage pool to use (optional, default: local-lvm)."
    echo "  --help       Display this help message."
    exit 1
}

# Default storage
STORAGE="local-lvm"

# Parse command-line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --vmid) VMID="$2"; shift ;;
        --storage) STORAGE="$2"; shift ;;
        --help) usage ;;
        *) echo "Unknown parameter passed: $1"; usage ;;
    esac
    shift
done

# Check for required VMID argument
if [[ -z $VMID ]]; then
    echo "Error: VMID is required."
    usage
fi

# Fetch a cloud-init image of Ubuntu
wget -q https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img

# If you have multiple nodes and run a Proxmox cluster, try and run this on the node with the maximum storage.
# If you are not on a Proxmox subscription, disable any enterprise repos:
# The enterprise repos can be disabled by navigating to the node name ('pve') and going into the 'Repositories' section.

# Update and install necessary tools
apt update -y
apt install -y libguestfs-tools
virt-customize -a focal-server-cloudimg-amd64.img --install qemu-guest-agent

# Create a base VM with the right configuration
echo "Creating VM with ID: $VMID and storage: $STORAGE"
qm create $VMID --name "ubuntu-2204-template" --memory 2048 --cores 2 --net0 virtio,bridge=vmbr0
qm importdisk $VMID focal-server-cloudimg-amd64.img $STORAGE
qm set $VMID --scsihw virtio-scsi-pci --scsi0 $STORAGE:vm-$VMID-disk-0
qm set $VMID --boot c --bootdisk scsi0
qm set $VMID --ide2 $STORAGE:cloudinit
qm set $VMID --serial0 socket --vga serial0
qm set $VMID --agent enabled=1

# Convert the VM into a template
qm template $VMID

echo "Template created successfully with VMID: $VMID on storage: $STORAGE"
