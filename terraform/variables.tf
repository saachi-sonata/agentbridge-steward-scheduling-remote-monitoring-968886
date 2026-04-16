variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
  sensitive   = true
}

variable "region" {
  description = "Azure region"
  type        = string
  default     = "eastus"
}

variable "instance_type" {
  description = "Azure VM size"
  type        = string
  default     = "Standard_D1"
}

variable "disk_size_gb" {
  description = "OS disk size in GB"
  type        = number
  default     = 50
}

variable "vnet_cidr" {
  description = "Virtual Network CIDR"
  type        = string
  default     = "10.0.0.0/16"
}

variable "ssh_public_key" {
  description = "SSH public key for VM access"
  type        = string
}

variable "allowed_ssh_cidrs" {
  description = "CIDRs allowed for SSH access"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "enable_public_ip" {
  description = "Assign a public IP"
  type        = bool
  default     = true
}

variable "enable_static_ip" {
  description = "Use static IP allocation"
  type        = bool
  default     = false
}

variable "additional_storage_gb" {
  description = "Additional managed disk size in GB (0 to skip)"
  type        = number
  default     = 0
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "production"
}

# --- Azure AI Foundry ---
variable "enable_foundry" {
  description = "Enable Azure AI Foundry agents for AI orchestration"
  type        = bool
  default     = false
}

variable "foundry_model" {
  description = "Model to deploy in Foundry (e.g., gpt-4o)"
  type        = string
  default     = "gpt-4o"
}
