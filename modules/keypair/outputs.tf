output "keypair_name" {
  description = "The name of the created OpenStack key pair"
  value       = openstack_compute_keypair_v2.keypair.name
}

