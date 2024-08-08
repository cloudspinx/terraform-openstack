variable "flavors" {
  description = "List of flavor configurations"
  type = list(object({
    name  = string
    ram   = number
    vcpus = number
    disk  = number
    swap  = number
  }))
}
