resource "azurerm_resource_group" "RgBlock" {
  name     = "nipunrgterraform"
  location = "Westus"
}

resource "azurerm_virtual_network" "VnetBlock" {
  name                = "Vnetterraform"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.RgBlock.location
  resource_group_name = azurerm_resource_group.RgBlock.name
}

resource "azurerm_subnet" "subnetnipBlock" {
  name                 = "Subnet1"
  resource_group_name  = azurerm_resource_group.RgBlock.name
  virtual_network_name = azurerm_virtual_network.VnetBlock.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "NippublicipBlock" {
  name                = "NipunPublicIp1"
  resource_group_name = azurerm_resource_group.RgBlock.name
  location            = azurerm_resource_group.RgBlock.location
  allocation_method   = "Static"


}

resource "azurerm_network_interface" "nicblock" {
  name                = "nipunnic"
  location            = azurerm_resource_group.RgBlock.location
  resource_group_name = azurerm_resource_group.RgBlock.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnetnipBlock.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.NippublicipBlock.id
  }
}

resource "azurerm_network_security_group" "nsgblock" {
  name                = "nsgterraform"
  location            = azurerm_resource_group.RgBlock.location
  resource_group_name = azurerm_resource_group.RgBlock.name

  security_rule {
    name                       = "allow_ssh"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}
resource "azurerm_linux_virtual_machine" "Vmblock" {
  name                            = "VMNipunterraform"
  resource_group_name             = azurerm_resource_group.RgBlock.name
  location                        = azurerm_resource_group.RgBlock.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "test@12345678"
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.nicblock.id,
  ]
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }


}
