variable "my_ip" {
  description = "My public IP address with /32"
  type        = string
}

variable "admin_username" {
  description = "The admin username of the server"
  type        = string
}

variable "rsa_public_key" {
  description = "The SSH public key to install on the VM"
  type        = string
}

variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}

variable "client_id" {
  description = "Azure Service Principal Client ID"
  type        = string
}

variable "client_secret" {
  description = "Azure Service Principal Client Secret"
  type        = string
}

variable "tenant_id" {
  description = "Azure Tenant ID"
  type        = string
}