// Prefix for all resources

prefix_name = "rancher-"
location = "Central US"

// User - modify accordingly

user = {
  username = "your_name"
}

// Network - modify accordingly

vnet_address_space = "10.3.0.0/16"
subnet_front_address_prefix = "10.3.1.0/24"
subnet_address_prefix = "10.3.2.0/24"

// Virtual machine

// Need to ensure the below is correct for the zone mentioned above - some VM's are not available in every location

vm_rancher_server = {
  computer_name = "server" // Concatenated with ${var.prefix_name}
  private_ip = "10.3.2.4"
  vm_size = "Standard_DS1_v2"
}