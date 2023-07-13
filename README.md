# proxmox-homelab-kube

- A complete package built using shell, Terrafrom and Ansible to create a fully running k8s cluster in a proxmox installation.
- Most values default to the default installation settings of proxmox, the comments in the files should help you change any if you need to.
- Has been tested with proxmox 7.x and 8.x.

## Steps:

#### Create a VM template
- SSH into your proxmox node
- Run  `wget -O template.sh https://raw.githubusercontent.com/ash0ne/proxmox-homelab-kube/main/prepare-vm-template.sh && . template.sh`

#### Create an API key and add permissions
- Click on Datacenter -> Permissions -> API Tokens
- Click on 'Add' and create a token for one of your admin users. Ideally this must be an admin user in the pve realm but any admin user works just fine.
- Lastly, do not forget to add the permission for the API token by going to Permissions -> Add. This needs to be done even if the user acssociated with the token already has permissions.
  
  ![Screenshot 2023-07-13 071644](https://github.com/ash0ne/proxmox-homelab-kube/assets/136186619/3b3def4e-e759-4185-8e2b-7d5846d11f97)

#### Update values in terraform.tfvars
- Update everything to the right values in `terraform.tfvars`
- A sample tfvars file is added at `./terrafrom/terraform.tfvars`
