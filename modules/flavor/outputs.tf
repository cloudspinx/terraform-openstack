output "flavor_ids" {
 value = { for flavor in openstack_compute_flavor_v2.flavor : flavor.name => flavor.id }
}
