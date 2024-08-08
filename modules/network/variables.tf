variable "network_name" {
  description = "The name of the private network"
  type        = string
}

variable "subnet_name" {
  description = "The name of the private subnet"
  type        = string
}

variable "subnet_cidr" {
  description = "The CIDR block of the private subnet"
  type        = string
}

variable "external_network_name" {
  description = "The name of the external network"
  type        = string
}

variable "region" {
  description = "The region in which to create the network resources"
  type        = string
  default     = "RegionOne"
}

variable "dns_nameservers" {
  description = "List of DNS nameservers for the subnet"
  type        = list(string)
  default     = ["8.8.8.8", "8.8.4.4"]
}