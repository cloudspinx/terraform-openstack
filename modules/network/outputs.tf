output "network_id" {
  description = "The ID of the private network"
  value       = openstack_networking_network_v2.private_network.id
}

output "subnet_id" {
  description = "The ID of the private subnet"
  value       = openstack_networking_subnet_v2.private_subnet.id
}

output "router_id" {
  description = "The ID of the router"
  value       = openstack_networking_router_v2.router.id
}