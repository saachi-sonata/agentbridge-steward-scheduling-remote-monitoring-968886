terraform {
  required_version = ">= 1.5"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.85"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = "rg-agentbridge-${var.environment}-steward---scheduling--remote-monitoring-"
  location = var.region
  tags = {
    Environment = var.environment
    ManagedBy   = "terraform"
    Blueprint   = "Steward • Scheduling (Remote Monitoring)"
  }
}

# Virtual Network
resource "azurerm_virtual_network" "main" {
  name                = "vnet-agentbridge-steward---scheduling--remote-monitoring-"
  address_space       = [var.vnet_cidr]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_subnet" "main" {
  name                 = "snet-agentbridge-steward---scheduling--remote-monitoring-"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [cidrsubnet(var.vnet_cidr, 8, 1)]
}

# Network Security Group
resource "azurerm_network_security_group" "main" {
  name                = "nsg-agentbridge-steward---scheduling--remote-monitoring-"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  security_rule {
    name                       = "SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefixes    = var.allowed_ssh_cidrs
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTP"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTPS"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Application"
    priority                   = 400
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5678"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Public IP
resource "azurerm_public_ip" "main" {
  count               = var.enable_public_ip ? 1 : 0
  name                = "pip-agentbridge-steward---scheduling--remote-monitoring-"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = var.enable_static_ip ? "Static" : "Dynamic"
  sku                 = "Standard"
}

# Network Interface
resource "azurerm_network_interface" "main" {
  name                = "nic-agentbridge-steward---scheduling--remote-monitoring-"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.enable_public_ip ? azurerm_public_ip.main[0].id : null
  }
}

resource "azurerm_network_interface_security_group_association" "main" {
  network_interface_id      = azurerm_network_interface.main.id
  network_security_group_id = azurerm_network_security_group.main.id
}

# Linux Virtual Machine
resource "azurerm_linux_virtual_machine" "main" {
  name                  = "vm-agentbridge-steward---scheduling--remote-monitoring-"
  resource_group_name   = azurerm_resource_group.main.name
  location              = azurerm_resource_group.main.location
  size                  = var.instance_type
  admin_username        = "azureuser"
  network_interface_ids = [azurerm_network_interface.main.id]

  admin_ssh_key {
    username   = "azureuser"
    public_key = var.ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = var.disk_size_gb
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }

  custom_data = base64encode(file("${path.module}/scripts/cloud-init.yml"))

  tags = {
    Environment = var.environment
    Blueprint   = "Steward • Scheduling (Remote Monitoring)"
    ManagedBy   = "terraform"
  }
}

# Managed Data Disk
resource "azurerm_managed_disk" "data" {
  count                = var.additional_storage_gb > 0 ? 1 : 0
  name                 = "disk-agentbridge-steward---scheduling--remote-monitoring--data"
  location             = azurerm_resource_group.main.location
  resource_group_name  = azurerm_resource_group.main.name
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = var.additional_storage_gb
}

resource "azurerm_virtual_machine_data_disk_attachment" "data" {
  count              = var.additional_storage_gb > 0 ? 1 : 0
  managed_disk_id    = azurerm_managed_disk.data[0].id
  virtual_machine_id = azurerm_linux_virtual_machine.main.id
  lun                = 0
  caching            = "ReadWrite"
}

# ═══════════════════════════════════════════════════════════════════
# Azure AI Foundry (Cognitive Services + Agent Orchestration)
# Creates AI Services account, model deployment, and agents via REST
# ═══════════════════════════════════════════════════════════════════

# AI Services account (hosts Foundry agents)
resource "azurerm_cognitive_account" "ai_services" {
  count                 = var.enable_foundry ? 1 : 0
  name                  = "agentbridge-steward---scheduling--remote-monitoring--ai"
  location              = azurerm_resource_group.main.location
  resource_group_name   = azurerm_resource_group.main.name
  kind                  = "AIServices"
  sku_name              = "S0"
  custom_subdomain_name = "agentbridge-steward---scheduling--remote-monitoring--ai"

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = var.environment
    Blueprint   = "Steward • Scheduling (Remote Monitoring)"
    ManagedBy   = "terraform"
  }
}

# Model deployment (GPT-4o or configured model)
resource "azurerm_cognitive_deployment" "model" {
  count                = var.enable_foundry ? 1 : 0
  name                 = var.foundry_model
  cognitive_account_id = azurerm_cognitive_account.ai_services[0].id

  model {
    format  = "OpenAI"
    name    = var.foundry_model
    version = "2024-11-20"
  }

  sku {
    name     = "Standard"
    capacity = 10
  }
}

# User-assigned managed identity for VM → Foundry access
resource "azurerm_user_assigned_identity" "vm_foundry" {
  count               = var.enable_foundry ? 1 : 0
  name                = "agentbridge-steward---scheduling--remote-monitoring--vm-identity"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

# Grant VM identity access to Cognitive Services
resource "azurerm_role_assignment" "vm_cognitive_user" {
  count                = var.enable_foundry ? 1 : 0
  scope                = azurerm_cognitive_account.ai_services[0].id
  role_definition_name = "Cognitive Services User"
  principal_id         = azurerm_user_assigned_identity.vm_foundry[0].principal_id
}

# Create Foundry agents via local-exec (no native TF resource yet)
resource "null_resource" "foundry_agents" {
  count = var.enable_foundry ? 1 : 0

  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command     = <<-EOT
      ENDPOINT="https://agentbridge-steward---scheduling--remote-monitoring--ai.services.ai.azure.com"
      echo "Creating Foundry agents at $ENDPOINT..."
      
    EOT
  }

  depends_on = [azurerm_cognitive_deployment.model]
}
