variable "my_ip" {
  description = "My public IP address with /32"
  type        = string
}

variable "public_ssh_key" {
  description = "The SSH public key to install on the VM"
  type        = string
}
