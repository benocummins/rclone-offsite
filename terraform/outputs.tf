output "vm_public_ip" {
    value       = azurerm_public_ip.public_ip.ip_address
    description = "The public IP address of the VM"
}

ouput "admin_username" {
    value       = var.admin_username
    description = "The administrator username for the VM"
    sensitive   = false
}