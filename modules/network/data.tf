# Data source to get the external network ID
data "openstack_networking_network_v2" "external_network" {
  name = var.external_network_name
}