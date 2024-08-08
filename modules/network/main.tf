# Create a private network
resource "openstack_networking_network_v2" "private_network" {
  name           = var.network_name
  admin_state_up = true
}

# Create a private subnet
resource "openstack_networking_subnet_v2" "private_subnet" {
  name            = var.subnet_name
  network_id      = openstack_networking_network_v2.private_network.id
  cidr            = var.subnet_cidr
  ip_version      = 4
  dns_nameservers = var.dns_nameservers
}

# Create a router
resource "openstack_networking_router_v2" "router" {
  name                = "${var.network_name}-router"
  admin_state_up      = true
  external_network_id = data.openstack_networking_network_v2.external_network.id
}

# Attach the private subnet to the router
resource "openstack_networking_router_interface_v2" "router_interface" {
  router_id = openstack_networking_router_v2.router.id
  subnet_id = openstack_networking_subnet_v2.private_subnet.id
}