# Define instance creation resource
resource "openstack_compute_instance_v2" "instance" {
  for_each = { for idx, instance in var.instances : idx => instance }
  
  name            = each.value.name
  image_id        = each.value.image_id
  flavor_id       = each.value.flavor_id
  key_pair        = each.value.key_pair
  security_groups = each.value.security_groups
  
  network {
    uuid          = each.value.network_id
    fixed_ip_v4   = each.value.fixed_ip != "" ? each.value.fixed_ip : null
  }
  # Conditionally include userdata if provided
  user_data = each.value.userdata_file != null ? file(each.value.userdata_file) : null
  metadata = {
    role = each.value.metadata_role
  }
}

# Flatten the volume definitions and create a unique map for volumes
locals {
  volumes_list = flatten([
    for instance_idx, instance in var.instances : [
      for volume_idx, volume in lookup(instance, "volumes", []) : {
        instance_idx = instance_idx
        volume_idx   = volume_idx
        volume       = volume
        volume_key   = "${instance_idx}-${volume_idx}"
      }
    ]
  ])
}

# Define volumes
resource "openstack_blockstorage_volume_v3" "volume" {
  for_each = { for vol in local.volumes_list : vol.volume_key => vol }

  name              = "volume-${each.value.instance_idx}-${each.value.volume_idx}-${openstack_compute_instance_v2.instance[each.value.instance_idx].name}"
  size              = each.value.volume.volume_size
}

# Attach volume(s) to instance
resource "openstack_compute_volume_attach_v2" "volume_attachment" {
  for_each = { for vol in local.volumes_list : vol.volume_key => vol }

  instance_id = openstack_compute_instance_v2.instance[each.value.instance_idx].id
  volume_id   = openstack_blockstorage_volume_v3.volume[each.key].id
}

# Null resource to wait for instances creation
resource "null_resource" "wait_for_instances" {
  for_each = { for idx, instance in var.instances : idx => instance if instance.assign_floating_ip }

  provisioner "local-exec" {
    command = "echo Instance ${each.key} created"
  }

  depends_on = [openstack_compute_instance_v2.instance]
}
# Resource to create floating IPs
resource "openstack_networking_floatingip_v2" "fip" {
  for_each = { for idx, instance in var.instances : idx => instance if instance.assign_floating_ip }
  pool     = var.floating_ip_pool
}

# Resource to associate floating IPs with ports
resource "openstack_networking_floatingip_associate_v2" "fip_assoc" {
  for_each = { for idx, instance in var.instances : idx => instance if instance.assign_floating_ip }
  floating_ip = openstack_networking_floatingip_v2.fip[each.key].address
  port_id     = data.openstack_networking_port_v2.port_by_fixed_ip[each.key].id
}
