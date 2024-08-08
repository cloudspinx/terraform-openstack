# Fetch network details
data "openstack_networking_network_v2" "network" {
  name = var.floating_ip_pool
}

# Data source to fetch port ID using the instance's fixed IP
data "openstack_networking_port_v2" "port_by_fixed_ip" {
  for_each = { for idx, instance in var.instances : idx => instance if instance.assign_floating_ip }
  fixed_ip = each.value.fixed_ip
  depends_on = [null_resource.wait_for_instances]
}
