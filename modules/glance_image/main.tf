# Define the OpenStack image resource
resource "openstack_images_image_v2" "image" {
  name              = var.image_name
  disk_format       = var.disk_format
  container_format  = var.container_format
  visibility        = var.visibility
  local_file_path   = var.local_file_path

  # Optionally, add other properties as needed
  min_disk_gb       = var.min_disk_gb
  min_ram_mb        = var.min_ram_mb
  tags              = var.tags
}


