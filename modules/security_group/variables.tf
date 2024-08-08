variable "security_group_name" {
  description = "The name of the security group"
  type        = string
}

variable "rules" {
  description = "List of security group rules"
  type = list(object({
    direction        = string
    ethertype        = string
    protocol         = string
    remote_ip_prefix = string
  }))
}