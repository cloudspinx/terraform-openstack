# OpenStack Terraform modules

Terraform modules which creates the following resources on OpenStack:

- create nova instances
- Cretae private networks
- Create security groups
- Create nova flavors
- Create keypair


## Defining openstack provider

Customize the following configurations to create 

```hcl
# Define required providers
terraform {
  required_providers {
    openstack = {
      source = "hashicorp/openstack"
    }
  }
}

# Configure the OpenStack Provider
provider "openstack" {
  user_name   = "admin"
  tenant_name = "admin"
  password    = "pwd"
  auth_url    = "http://myauthurl:5000/v3"
  region      = "RegionOne"
}
```

## Uploading an image to OpenStack Glance

```hcl
module "glance_image" {
  source = "git::https://github.com/cloudspinx/terraform-openstack.git//modules/glance_image?ref=main"

  image_name        = "my-image"
  disk_format       = "qcow2"
  container_format  = "bare"
  visibility        = "public"
  local_file_path   = "path/to/local/image.qcow2"
  #min_disk_gb      = 10
  #min_ram_mb       = 512
  #tags             = ["tag1", "tag2"]
}


## Keypair creation

```hcl
module "keypair" {

  source       = "git::https://github.com/cloudspinx/terraform-openstack.git//modules/keypair?ref=main"
  keypair_name = "my-keypair"
  public_key   = file("path/to/your/public/key.pub")
}
```

## flavor creation

```hcl
module "flavors" {
  source = "git::https://github.com/cloudspinx/terraform-openstack.git//modules/flavor?ref=main"

  flavors = [
    {
      name      = "small"
      ram       = 2048
      vcpus     = 1
      disk      = 20
      swap      = 0
      is_public = true
    },
    {
      name      = "medium"
      ram       = 4096
      vcpus     = 2
      disk      = 40
      swap      = 0
      is_public = true
    },
    {
      name      = "large"
      ram       = 8192
      vcpus     = 4
      disk      = 80
      swap      = 0
      is_public = true
    }
  ]
}
```

## Network creation

```hcl
module "network" {
  source = "git::https://github.com/cloudspinx/terraform-openstack.git//modules/network?ref=main"

  network_name          = privatenet
  subnet_name           = privatenet_subnet
  subnet_cidr           = 172.34.50.0/24
  external_network_name = public
  region                = RegionOne
  dns_nameservers       = ["8.8.8.8", "8.8.4.4"]
}
```

## Security group creation

```hcl
module "security_group" {
  source = "git::https://github.com/cloudspinx/terraform-openstack.git//modules/security_group?ref=main"

  security_group_name = "test_sg"
  rules = [
    {
      direction = "ingress"
      ethertype = "IPv4"
      protocol  = "icmp"
      remote_ip_prefix = "0.0.0.0/0"
    },
    {
      direction = "ingress"
      ethertype = "IPv4"
      protocol  = "tcp"
      remote_ip_prefix = "0.0.0.0/0"
    },
    {
      direction = "egress"
      ethertype = "IPv4"
      protocol  = "tcp"
      remote_ip_prefix = "0.0.0.0/0"
    }
  ]
}
```

## Instances creation

What you can optionally enable:
- Assigning fixed ip `fixed_ip`, set to `null` to use dhcp
- Assigning floating IP to the instance `assign_floating_ip`, disable by setting it to `false`
- Using cloud init data, specify path to enable, for example `./cloud-init.yml`, disable with `null`
- Attaching volumes to the instance. Only use if you have "Cinder" configured. Disable by setting to `[]`

### Single instance without block storage

```hcl
module "instance" {
  source = "git::https://github.com/cloudspinx/terraform-openstack.git//modules/instance?ref=main"
  
  floating_ip_pool = "public"
  instances = [
         {
            name               = "instancename"
            image_id           = "imageid"
            #image_id          = module.glance_image.image_id
            flavor_id          = module.flavors.flavor_ids["medium"]
            key_pair           = module.keypair.keypair_name
            network_id         = module.network.network_id
            fixed_ip           = "172.34.50.11"
            assign_floating_ip = true
            security_groups    = [module.security_group.security_group_id]
            userdata_file      = null
            metadata_role      = "web-server"
            volumes            = []
        }
        ]
}

### Creating instance with 

module "instance" {
  source = "git::https://github.com/cloudspinx/terraform-openstack.git//modules/instance?ref=main"
  
  floating_ip_pool = "public"
  instances = [
         {
            name               = "instancename"
            image_id           = "imageid"
            #image_id          = module.glance_image.image_id
            flavor_id          = module.flavors.flavor_ids["medium"]
            key_pair           = "keypair"
            network_id         = module.network.network_id
            fixed_ip           = null
            assign_floating_ip = false
            security_groups    = [module.security_group.security_group_id]
            userdata_file      = "./cloud-init.yaml"
            metadata_role      = "web-server"
            volumes            = [
                {
                    volume_size       = 50
                }
            ]
        }
        ]
}

Example on attaching more than one disk volume

```hcl
            volumes            = [
                {
                    volume_size       = 50
                },
                {
                    volume_size       = 50
                }
            ]
```
