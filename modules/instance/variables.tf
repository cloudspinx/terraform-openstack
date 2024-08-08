variable "instances" {
  description = "List of instance configurations or a single instance configuration."
  type = list(object({
    name                = string
    image_name          = string
    flavor_id           = string
    key_pair            = string
    network_id          = string
    security_groups     = list(string)
    fixed_ip            = optional(string)
    assign_floating_ip  = bool
    metadata_role       = string
    userdata_file       = optional(string, null)
    volumes = list(object({
        volume_size       = number
        }))
    }))
}

variable "floating_ip_pool" {
  description = "The name of the floating IP pool"
  type        = string
  default     = "public"
}
