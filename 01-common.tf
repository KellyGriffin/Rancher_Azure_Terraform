variable "client_id" {}
variable "client_secret" {}
variable "location" {}
variable "prefix_name" {}
variable "ssh_public_key_file_path" {}
variable "ssh_private_key_file_path" {}
variable "subnet_address_prefix" {}
variable "subscription_id" {}
variable "tenant_id" {}
variable "user" { type = "map" }
variable "vnet_address_space" {}

# Configure the Microsoft Azure Provider - update as per your site
provider "azurerm" {
client_id       = "xxx"
client_secret   = "xxx"
tenant_id       = "xxx"
subscription_id = "xxx"
}

# create a resource group
resource "azurerm_resource_group" "rancher-rg" {
  name      = "${var.prefix_name}rg"
  location  = "${var.location}"
}

# create a resource network security group for subnet
resource "azurerm_network_security_group" "rancher-subnet-nsg" {
  name                = "${var.prefix_name}subnet-nsg"
  location            = "${azurerm_resource_group.rancher-rg.location}"
  resource_group_name = "${azurerm_resource_group.rancher-rg.name}"

  security_rule {
    access                      = "Allow"
    destination_address_prefix  = "*"
    destination_port_range      = "22"
    direction                   = "Inbound"
    name                        = "Allow_SSH"
    priority                    = 200
    protocol                    = "Tcp"
    source_address_prefix       = "*"
    source_port_range           = "*"
  }

  security_rule {
    access                      = "Allow"
    destination_address_prefix  = "*"
    destination_port_range      = "443"
    direction                   = "Inbound"
    name                        = "Allow_HTTPS"
    priority                    = 101
    protocol                    = "Tcp"
    source_address_prefix       = "*"
    source_port_range           = "*"
  }
}

# create a virtual network
resource "azurerm_virtual_network" "rancher-vnet" {
  name                = "${var.prefix_name}vnet"
  resource_group_name = "${azurerm_resource_group.rancher-rg.name}"
  address_space       = ["${var.vnet_address_space}"]
  location            = "${azurerm_resource_group.rancher-rg.location}"
}

# create subnet
resource "azurerm_subnet" "rancher-subnet" {
  address_prefix = "${var.subnet_address_prefix}"
  name = "${var.prefix_name}subnet"
  azurerm_subnet_network_security_group_association = "${azurerm_network_security_group.rancher-subnet-nsg.id}"
  resource_group_name = "${azurerm_resource_group.rancher-rg.name}"
  virtual_network_name = "${azurerm_virtual_network.rancher-vnet.name}"
}