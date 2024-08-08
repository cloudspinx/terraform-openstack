# Output volume IDs and names
output "volume_ids_and_names" {
  value = { for volume in openstack_blockstorage_volume_v3.volume :
    volume.id => volume.name
  }
}

# Output volume attachment information with instance names
output "volume_attachments_with_names" {
  value = [
    for attachment in openstack_compute_volume_attach_v2.volume_attachment :
    {
      instance_name = lookup({ for inst in openstack_compute_instance_v2.instance : inst.id => inst.name }, attachment.instance_id, "unknown")
      volume_id     = attachment.volume_id
    }
  ]
}

output "instance_names_and_ips" {
  value = { for idx, instance in openstack_compute_instance_v2.instance : idx => {
      name        = instance.name
      fixed_ip    = instance.network[0].fixed_ip_v4
      access_ip_v4 = instance.access_ip_v4
      floating_ip = try(openstack_networking_floatingip_v2.fip[idx].address, null)
    }
  }
}
