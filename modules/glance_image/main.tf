# Define the OpenStack image resource
resource "openstack_images_image_v2" "image" {
  name              = var.image_name
  disk_format       = var.disk_format
  container_format  = var.container_format
  visibility        = var.visibility
  image_url         = var.image_url
  image_path        = var.image_path

  # Optionally, add other properties as needed
  min_disk          = var.min_disk
  min_ram           = var.min_ram
  tags              = var.tags

  # Data for the image can be fetched from a URL or a local path
  # (if both are provided, URL has higher priority)
  # image_url       = var.image_url
  # image_path      = var.image_path
}


