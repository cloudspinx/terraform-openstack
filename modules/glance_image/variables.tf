variable "image_name" {
  description = "The name of the image"
  type        = string
}

variable "disk_format" {
  description = "The disk format of the image (e.g., qcow2, raw)"
  type        = string
}

variable "container_format" {
  description = "The container format of the image (e.g., bare, ovf)"
  type        = string
}

variable "visibility" {
  description = "The visibility of the image (e.g., public, private)"
  type        = string
}

variable "image_source_url" {
  description = "The URL to download the image from (optional, overrides image_path)"
  type        = string
  default     = ""
}

variable "local_file_path" {
  description = "The local file path of the image to upload (optional)"
  type        = string
  default     = ""
}

variable "min_disk_gb" {
  description = "The minimum disk size required to boot the image"
  type        = number
  default     = 0
}

variable "min_ram_mb" {
  description = "The minimum RAM size required to boot the image"
  type        = number
  default     = 0
}

variable "tags" {
  description = "Tags for the image"
  type        = list(string)
  default     = []
}
