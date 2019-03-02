variable "vm_rancher_server" { type = "map" }

# create network interface rancher server
resource "azurerm_network_interface" "rancher-server-inet" {
  location = "${azurerm_resource_group.rancher-rg.location}"
  name = "${var.prefix_name}${var.vm_rancher_server["computer_name"]}-inet"
  resource_group_name = "${azurerm_resource_group.rancher-rg.name}"

  "ip_configuration" {
    name = "${var.prefix_name}${var.vm_rancher_server["computer_name"]}-inet-ip-conf"
    private_ip_address_allocation = "static"
    private_ip_address = "${var.vm_rancher_server["private_ip"]}"
    public_ip_address_id = "${azurerm_public_ip.rancher-server-public-ip.id}"
    subnet_id = "${azurerm_subnet.rancher-subnet.id}"
  }
}
# allocate Public IP for rancher server vm
resource "azurerm_public_ip" "rancher-server-public-ip" {
  location = "${azurerm_resource_group.rancher-rg.location}"
  name = "${var.prefix_name}${var.vm_rancher_server["computer_name"]}-public-ip"
  allocation_method = "Dynamic"
  resource_group_name = "${azurerm_resource_group.rancher-rg.name}"
}
data "azurerm_public_ip" "rancher-server-public-ip" {
  name = "${azurerm_public_ip.rancher-server-public-ip.name}"
  resource_group_name = "${azurerm_resource_group.rancher-rg.name}"
  depends_on = ["azurerm_virtual_machine.rancher-server"]
}
# create vm rancher server
resource "azurerm_virtual_machine" "rancher-server" {
  delete_os_disk_on_termination = false
  location = "${azurerm_resource_group.rancher-rg.location}"
  name = "${var.prefix_name}${var.vm_rancher_server["computer_name"]}"
  network_interface_ids = ["${azurerm_network_interface.rancher-server-inet.id}"]
  resource_group_name = "${azurerm_resource_group.rancher-rg.name}"
  vm_size = "${var.vm_rancher_server["vm_size"]}"

  os_profile {
    admin_username = "${var.user["username"]}"
    computer_name = "${var.prefix_name}${var.vm_rancher_server["computer_name"]}"
  }
  os_profile_linux_config {
   disable_password_authentication = true
    ssh_keys {
      path = "/home/${var.user["username"]}/.ssh/authorized_keys"
      key_data = "${file("${var.ssh_public_key_file_path}")}"
    }
  }
  "storage_os_disk" {
    caching = "ReadWrite"
    create_option = "FromImage"
    managed_disk_type = "Standard_LRS"
    name = "${var.prefix_name}${var.vm_rancher_server["computer_name"]}-osdisk1"
  }
  storage_image_reference {
    publisher = "Canonical"
    offer = "UbuntuServer"
    sku = "18.04-LTS"
    version = "latest"
  }
}
data "template_file" "rancher-server-provision-script" {
  template = "${file("${path.module}/scripts/provision-rancher-server.sh")}"

  vars {
    rancher_server_private_ip = "${var.vm_rancher_server["private_ip"]}"
    username = "${var.user["username"]}"
  }
}
resource "null_resource" "rancher-server-provision" {
  connection {
    host = "${data.azurerm_public_ip.rancher-server-public-ip.ip_address}"
    private_key = "${file("${var.ssh_private_key_file_path}")}"
    type = "ssh"
    user = "${var.user["username"]}"
  }
  provisioner "file" {
    destination = "/home/${var.user["username"]}/provision-rancher-server.sh"
    content = "${data.template_file.rancher-server-provision-script.rendered}"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /home/${var.user["username"]}/provision-rancher-server.sh",
      "sudo /home/${var.user["username"]}/provision-rancher-server.sh",
    ]
  }

  depends_on = ["azurerm_virtual_machine.rancher-server"]
}
output "Rancher Server IP address" {
  value = [
    "Rancher server: ${data.azurerm_public_ip.rancher-server-public-ip.ip_address}",
  ]
}