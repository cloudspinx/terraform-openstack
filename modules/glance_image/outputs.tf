output "image_id" {
  description = "The ID of the created OpenStack image"
  value       = openstack_images_image_v2.image.id
}

output "image_name" {
  description = "The name of the created OpenStack image"
  value       = openstack_images_image_v2.image.name
}
