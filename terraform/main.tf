provider "azurerm" {
    features{}
    subscription_id                 = var.subscription_id
    client_id                       = var.client_id
    client_secret                   = var.client_secret
    tenant_id                       = var.tenant_id
}

resource "azurerm_resource_group" "rg" {
    name                            = "rclone-offsite-rg"
    location                        = "East US" 
}

resource "azurerm_virtual_network" "vnet" {
    name                            = "rclone-offsite-vnet"
    address_space                   = ["10.100.0.0/16"]
    location                        = azurerm_resource_group.rg.location
    resource_group_name             = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet" {
    name                            = "rclone-offsite-subnet"
    resource_group_name             = azurerm_resource_group.rg.name
    virtual_network_name            = azurerm_virtual_network.vnet.name
    address_prefixes                = ["10.100.10.0/24"]
}

resource "azurerm_public_ip" "public_ip" {
    name                            = "rclone-offsite-public-ip"
    location                        = azurerm_resource_group.rg.location
    resource_group_name             = azurerm_resource_group.rg.name
    allocation_method               = "Static"
    sku                             = "Standard"
}

resource "azurerm_network_interface" "nic" {
    name                            = "rclone-offsite-nic"
    location                        = azurerm_resource_group.rg.location
    resource_group_name             = azurerm_resource_group.rg.name

    ip_configuration {
        name                            = "internal"
        subnet_id                       = azurerm_subnet.subnet.id
        private_ip_address_allocation   = "Dynamic"
        public_ip_address_id            = azurerm_public_ip.public_ip.id
    }
}

resource "azurerm_network_security_group" "nsg" {
    name                            = "rclone-offsite-nsg"
    location                        = azurerm_resource_group.rg.location
    resource_group_name             = azurerm_resource_group.rg.name

    security_rule {
        name                        = "Allow-SSH"
        priority                    = 1000
        direction                   = "Inbound"
        access                      = "Allow"
        protocol                    = "Tcp"
        source_port_range           = "*"
        destination_port_range      = "22"
        source_address_prefix       = [var.my_ip, "20.29.0.0/16"] # Include GitHub Actions IP range
        destination_address_prefix  = "*"
    }

    security_rule {
        name                        = "Allow-RDP"
        priority                    = 1001
        direction                   = "Inbound"
        access                      = "Allow"
        protocol                    = "Tcp"
        source_port_range           = "*"
        destination_port_range      = "3389"
        source_address_prefix       = var.my_ip
        destination_address_prefix  = "*"
    }
}

resource "azurerm_network_interface_security_group_association" "nic_nsg" {
    network_interface_id           = azurerm_network_interface.nic.id
    network_security_group_id       = azurerm_network_security_group.nsg.id
}

resource "azurerm_linux_virtual_machine" "vm" {
    name                            = "rclone-offsite-vm"
    resource_group_name             = azurerm_resource_group.rg.name
    location                        = azurerm_resource_group.rg.location
    size                            = "Standard_B1s" # Small and cheap
    admin_username                  = var.admin_username
    admin_password                  = var.admin_password

    network_interface_ids           = [
        azurerm_network_interface.nic.id,
    ]

    admin_ssh_key {
        username              = var.admin_username
        public_key            = var.rsa_public_key 
    }

    os_disk {
        caching                     = "ReadWrite"
        storage_account_type        = "Standard_LRS"
    }

    source_image_reference {
        publisher                   = "Canonical"
        offer                       = "0001-com-ubuntu-server-jammy"
        sku                         = "22_04-lts-gen2"
        version                     = "latest"
    }
    
    custom_data = filebase64("${path.module}/cloud-init.yaml")
}