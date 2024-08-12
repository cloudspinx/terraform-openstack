# Fetch network details
data "openstack_networking_network_v2" "network" {
  name = var.floating_ip_pool
}
