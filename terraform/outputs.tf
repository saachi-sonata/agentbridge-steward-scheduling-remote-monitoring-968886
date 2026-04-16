output "vm_name" {
  description = "Virtual machine name"
  value       = azurerm_linux_virtual_machine.main.name
}

output "resource_group" {
  description = "Resource group name"
  value       = azurerm_resource_group.main.name
}

output "public_ip" {
  description = "Public IP address"
  value       = var.enable_public_ip ? azurerm_public_ip.main[0].ip_address : null
}

output "ssh_command" {
  description = "SSH connection command"
  value       = var.enable_public_ip ? "ssh azureuser@${azurerm_public_ip.main[0].ip_address}" : "Use Azure Bastion or VPN"
}

output "application_url" {
  description = "AgentBridge workflow editor URL"
  value       = var.enable_public_ip ? "http://${azurerm_public_ip.main[0].ip_address}:5678" : null
}

output "health_url" {
  description = "Health check endpoint"
  value       = var.enable_public_ip ? "http://${azurerm_public_ip.main[0].ip_address}/health" : null
}

output "console_url" {
  description = "Azure Portal link"
  value       = "https://portal.azure.com/#@/resource${azurerm_linux_virtual_machine.main.id}"
}

# --- Foundry AI Orchestration Outputs ---
output "foundry_endpoint" {
  description = "Azure AI Foundry endpoint"
  value       = var.enable_foundry ? "https://agentbridge-steward---scheduling--remote-monitoring--ai.services.ai.azure.com" : ""
}

output "foundry_portal_url" {
  description = "Azure AI Foundry portal link"
  value       = var.enable_foundry ? "https://ai.azure.com/resource/${azurerm_cognitive_account.ai_services[0].id}" : ""
}

output "foundry_model_deployment" {
  description = "Deployed model name"
  value       = var.enable_foundry ? var.foundry_model : ""
}
