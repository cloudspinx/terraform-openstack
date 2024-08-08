variable "keypair_name" {
  description = "The name of the OpenStack key pair"
  type        = string
}

variable "public_key" {
  description = "The public key to be used for the key pair"
  type        = string
}

variable "delete_keypair" {
  description = "Whether to delete the key pair. Set to true to delete."
  type        = bool
  default     = false
}
