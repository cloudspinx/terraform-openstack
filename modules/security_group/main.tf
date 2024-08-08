resource "openstack_networking_secgroup_v2" "secgroup" {
  name = var.security_group_name
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_rules" {
  count              = length(var.rules)
  direction          = var.rules[count.index].direction
  ethertype          = var.rules[count.index].ethertype
  protocol           = var.rules[count.index].protocol
  remote_ip_prefix   = var.rules[count.index].remote_ip_prefix
  security_group_id  = openstack_networking_secgroup_v2.secgroup.id
}
