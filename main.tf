#RESOURCE GROUP
resource "azurerm_resource_group" "RG1" {
    name = "RyanTerry-RG1"
    location = "West US"
}

#VIRTUAL NETWORL
resource "azurerm_virtual_network" "Vnet1" {
    name = "RyanTerry-Vnet1"
    location = azurerm_resource_group.RG1.location
    resource_group_name = azurerm_resource_group.RG1.name
    address_space = ["10.0.0.0/16"]
}

#SUBNET
resource "azurerm_subnet" "Subnet1" {
    name = "RyanTerry-Subnet1"
    resource_group_name = azurerm_resource_group.RG1.name
    virtual_network_name = azurerm_virtual_network.Vnet1.name
    address_prefixes = ["10.0.2.0/24"]
}

#NETWORK INTERFACE
resource "azurerm_network_interface" "NIC1" {
  name                = "RyanTerry-NIC1"
  location            = azurerm_resource_group.RG1.location
  resource_group_name = azurerm_resource_group.RG1.name

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = azurerm_subnet.Subnet1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.PIP1.id
  }
}

#VIRTUAL MACHINE
resource "azurerm_virtual_machine" "VM1" {
    name = "RyanTerry-VM1"
    location = azurerm_resource_group.RG1.location
    resource_group_name = azurerm_resource_group.RG1.name
    network_interface_ids = [azurerm_network_interface.NIC1.id]
    vm_size = "Standard_DS1_v2"

    storage_image_reference {
        publisher = "MicrosoftWindowsServer"
        offer     = "WindowsServer"
        sku       = "2019-datacenter-gensecond"
        version   = "latest"
    }
    storage_os_disk {
        name              = "RyanTerry-osdisk1"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Standard_LRS"
    }
    os_profile {
        computer_name  = "hostname"
        admin_username = "testadmin"
        admin_password = "Password1234!"
    }
    os_profile_windows_config {
      
    }
}

#NETWORK SECURITY GROUP
resource "azurerm_network_security_group" "NSG1" {
  name = "RyanTerry-NSG1"
  location = azurerm_resource_group.RG1.location
  resource_group_name = azurerm_resource_group.RG1.name

  security_rule {
    name                       = "test123"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

#PUBLIC ID
resource "azurerm_public_ip" "PIP1" {
    name = "RyanTerry-PIP1"
    location = azurerm_resource_group.RG1.location
    resource_group_name = azurerm_resource_group.RG1.name
    allocation_method = "Dynamic"  
}

#ASSOCIATE NSG WITH NI  
resource "azurerm_network_interface_security_group_association" "association" {
  network_interface_id      = azurerm_network_interface.NIC1.id
  network_security_group_id = azurerm_network_security_group.NSG1.id
}

#OUTPUTTING PIP
output "public_ip" {
  value = azurerm_public_ip.PIP1.ip_address
}