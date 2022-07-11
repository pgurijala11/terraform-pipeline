# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.12"
    }
  }
}

# Configure the Microsoft Azure Provider
terraform {
  backend "azurerm" {
    resource_group_name  = "pg-resource-group"
    storage_account_name = "terrformstgpg"
    container_name       = "tfstate"
    key                  = "__stgaccesskey__"
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}

  #subscription_id = "__subscriptionid__"
  #client_id       = "__clientid__"
  #client_secret   = "__clientsecret_"
  #tenant_id       = "__tenantid__"

  client_id       = "3db4ee92-abca-4697-8c36-963f312a03aa"
  tenant_id       = "3ad1301e-0b3b-448a-a29a-44059243af15"
  subscription_id = "df12aecd-0a40-4dff-b31f-725027247ff7"
  client_secret   = "z3K8Q~m_c5Vlg4nx3SbJumN0GNSdc1UWN5E7BaxV"
}

resource "azurerm_resource_group" "rg" {
  name     = var.rgname
  location = var.rglocation
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.prefix}-10"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = ["${var.vnet_cidr_prefix}"]
}

resource "azurerm_subnet" "sbn1" {
  name                 = "tf-sbn1"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.subnet_cidr_prefix[0]]
}

resource "azurerm_network_interface" "nic1" {
  name                = "terraform-nic1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.sbn1.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "vm1" {
  name                = "tf-vm1"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.nic1.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}

# creating 2nd VM
resource "azurerm_subnet" "sbn2" {
  name                 = "tf-sbn2"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.subnet_cidr_prefix[1]]
}


resource "azurerm_network_interface" "nic2" {
  name                = "terraform-nic2"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.sbn2.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "vm2" {
  name                = "tf-vm2"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.nic2.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}
                        
