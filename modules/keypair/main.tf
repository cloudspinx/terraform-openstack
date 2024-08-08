# Define the OpenStack key pair resource
resource "openstack_compute_keypair_v2" "keypair" {
  name       = var.keypair_name
  public_key = var.public_key
}

# Optionally, you can also define a resource to delete the keypair (if desired)
resource "openstack_compute_keypair_v2" "keypair_delete" {
  count = var.delete_keypair ? 1 : 0
  name  = var.keypair_name
}
