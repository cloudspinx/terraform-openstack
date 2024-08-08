resource "openstack_compute_flavor_v2" "flavor" {
  for_each = { for f in var.flavors : f.name => f }
  name        = each.value.name
  ram         = each.value.ram
  vcpus       = each.value.vcpus
  disk        = each.value.disk
  swap        = each.value.swap
  is_public   = each.value.is_public
}
