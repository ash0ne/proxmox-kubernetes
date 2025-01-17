
# replace with your proxmox server url
server_url = "http://<proxmox-server-url>/api2/json"

# Add the token details of the token. See README for generation instructions 
token_id     = "<token-id>"
token_secret = "<token-secret>"

# The initial ssh key that you would want to add to login to the kube nodes as user 'ubuntu'
ssh_key = "<ssh-key>"

# Default gateway
gateway = "192.168.0.1"

# Variables for configuring the VM which becomes the main k8s node
# Proxmox node where you want the VM for your k8s main node to go (For e.g. 'pve' or 'pve-01')
target_node_main = "<main-node-name>"

# Details of the static IP that you'd want for the main VM
ip_net_main = "192.168.0.100/24"

# Variables for configuring the VMs that become the agent k8s nodes
# Proxmox node where you want the VM for your k8s agent nodes to go (For e.g. 'pve' or 'pve-02')
target_node_agent = "<agent-node-name>"

# Details of the static IP that you'd want for the agent VMs
# IPs are created sequentially for all agent VMs. 
# For e.g. if agent VM resource count is 3 and you've defined the IP as 192.168.0.200, the IPs will be 192.168.0.200, 192.168.0.201 and 192.168.0.202
ip_net_agent = "192.168.0.200/24"

# Defaults to lvm change to zfs if you are using zfs
file_system = "lvm"
