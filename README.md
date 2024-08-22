# OpenStack Terraform modules

Terraform modules which creates the following resources on OpenStack (Work in progress, other modules to be added):

- ✅ Upload image to Glance
- ✅ Create SSH keypair
- ✅ Create nova flavors
- ✅ Create private networks
- ✅ Create security groups
- ✅ Create nova instances with attached cinder volumes (optional) and floating ip(optional)
- ❌ Dedicated Cinder volumes creation
- ❌ Magnum Container Platform
- ❌ Octavia Load balancer
- ❌ Swift Object Storage
- ❌ Manilla Shared Storage
- ❌ Trove databases

## 1. Using plain Terraform / OpenTofu

### Defining openstack provider

Customize the following configurations to configure OpenStack provider: 

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

For local state file you can use the following:
```hcl
terraform {
  backend "local" {
    path = "${path.module}/terraform.tfstate"
  }
}
```

### Uploading an image to OpenStack Glance

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
```


### SSH Keypair creation

```hcl
module "keypair" {

  source       = "git::https://github.com/cloudspinx/terraform-openstack.git//modules/keypair?ref=main"
  keypair_name = "my-keypair"
  public_key   = file("path/to/your/public/key.pub")
}
```

### Nova flavor creation

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

### Network creation

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

### Security group creation

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

### Instances creation

What you can optionally enable:
- Assigning fixed ip `fixed_ip`, set to `null` to use dhcp
- Assigning floating IP to the instance `assign_floating_ip`, disable by setting it to `false`
- Using cloud init data, specify path to enable, for example `./cloud-init.yml`, disable with `null`
- Attaching volumes to the instance. Only use if you have "Cinder" configured. Disable by setting to `[]`

#### Single instance without block storage

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
```

#### Creating instance with Cinder volume
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
```

##### Attaching multiple disk volumes

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


## 2. Using Terragrunt

Sample folder structure
```bash
.
├── flavors
│   └── terragrunt.hcl
├── glance_image
│   └── terragrunt.hcl
├── instance
│   └── terragrunt.hcl
├── keypair
│   └── terragrunt.hcl
├── network
│   └── terragrunt.hcl
├── security_group
│   └── terragrunt.hcl
└── terragrunt.hcl
```

Saple of the main parent `terragrunt.hcl` file:
```hcl
# ---------------------------------------------------------------------------------------------------------------------
# TERRAGRUNT CONFIGURATION
# This is the configuration for Terragrunt, a thin wrapper for Terraform and OpenTofu that helps keep your code DRY and
# maintainable: https://github.com/gruntwork-io/terragrunt
# 
locals {
    # Automatically load environment-level variables
    #environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
    user_name   = "admin"
    tenant_name = "admin"
    password    = "password"
    auth_url    = "http://myauthurl:5000/v3"
    region      = "RegionOne"
    user_domain_name = "Default"
    project_domain_name = "Default"
}

# Configure Terragrunt to automatically store tfstate files in an S3 bucket
#remote_state {
#    backend = "s3"
#    config = {
#        encrypt         = true
#        bucket          = "${get_env("TG_BUCKET_PREFIX", "")}terragrunt-example-tf-state-${local.account_name}-${local.aws_region}"
#        key             = "${path_relative_to_include()}/tf.tfstate"
#        region          = local.aws_region
#        dynamodb_table  = "tf-locks"
#    }
#}

# Generate OpenStack provider block
generate "provider" {
    path = "provider.tf"
    if_exists = "overwrite_terragrunt"
    contents  = <<EOF
  provider "openstack" {
    auth_url        = "${local.auth_url}"
    user_name       = "${local.user_name}"
    tenant_name     = "${local.tenant_name}"
    password        = "${local.password}"
    region          = "${local.region}"
    }
    EOF
}
```

In each terragrunt file, you can include the following if storing state file locally:

```hcl
remote_state {
  backend = "local"
  config = {
    path = "${get_parent_terragrunt_dir()}/${path_relative_to_include()}/terraform.tfstate"
  }

  generate = {
    path = "backend.tf"
    if_exists = "overwrite"
  }
}
```

### Keypair creation
- `keypair/terragrunt.hcl`:
```hcl
include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "git::https://github.com/cloudspinx/terraform-openstack.git//modules/glance_image?ref=main"
}

inputs = {
  keypair_name = "my-keypair"
  public_key   = file("path/to/your/public/key.pub")
}
```

### Glance image uploading
- `glance_image/terragrunt.hcl`:
```hcl
include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "git::https://github.com/cloudspinx/terraform-openstack.git//modules/glance_image?ref=main"
}

inputs = {
  image_name        = "my-image"
  disk_format       = "qcow2"
  container_format  = "bare"
  visibility        = "public"
  local_file_path   = "path/to/local/image.qcow2"
  #min_disk_gb      = 10
  #min_ram_mb       = 512
  #tags             = ["tag1", "tag2"]
}
```

### flavor creation
- `flavors/terragrunt.hcl`
```hcl
include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "git::https://github.com/cloudspinx/terraform-openstack.git//modules/flavor?ref=main"
}

inputs = {
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

### Network creation
- `network/terragrunt.hcl`
```hcl
include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "git::https://github.com/cloudspinx/terraform-openstack.git//modules/network?ref=main"
}

inputs = {
  network_name          = "privatenet"
  subnet_name           = "privatenet_subnet"
  subnet_cidr           = "172.34.50.0/24"
  external_network_name = "public"
  region                = "RegionOne"
  dns_nameservers       = ["8.8.8.8", "8.8.4.4"]
}
```

### Security group creation
- `security_group/terragrunt.hcl`
```hcl
include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "git::https://github.com/cloudspinx/terraform-openstack.git//modules/security_group?ref=main"
}

inputs = {
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

### Instance creation
- `instance/terragrunt.hcl`
```hcl
include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "git::https://github.com/cloudspinx/terraform-openstack.git//modules/instance?ref=main"
}

# Define dependencies
## Flavor
dependency "flavor" {
  config_path = "../flavors"
  mock_outputs = {
    flavor_ids = {
      "small"  = "temporary-flavor-id-small"
      "medium" = "temporary-flavor-id-medium"
    }
  }
}

## Security group
dependency "security_group" {
  config_path = "../security_group"
  mock_outputs = {
    security_group_id = "temporary-security-group-id"
}
}

## Keypair
dependency "keypair" {
  config_path = "../keypair"
  mock_outputs = {
    keypair_name = "temporary-keypair"
}
}

## Glance image
dependency "glance_image" {
  config_path = "../glance_image"
  mock_outputs = {
    keypair_name = "temporary-glance-image-id"
}
}

## Network
dependency "network" {
  config_path = "../network"
  mock_outputs = {
    network_id = "temporary-network-id"
    subnet_id  = "mock-subnet-id"
}
}

dependency "networking" {
  config_path = "../networking"
  mock_outputs_allowed_terraform_commands = ["validate", "plan", "apply"]
  mock_outputs = {
    network_id = "mock-network-id"
    subnet_id  = "mock-subnet-id"
  }
}

inputs = {
  floating_ip_pool = "public"
  instances = [
         {
          name               = "instancename"
          image_id           = dependency.glance_image.outputs.image_id
          #image_id          = "35ee8729-26b7-4e93-b045-71b13c574c73"
          flavor_id          = dependency.flavor.outputs.flavor_ids["medium"]
          key_pair           = dependency.keypair.outputs.keypair_name
          network_id         = dependency.network.outputs.network_id
	        security_groups    = [dependency.security_group.outputs.security_group_id]
          fixed_ip           = "172.34.50.11"
          assign_floating_ip = true
          userdata_file      = null
          metadata_role      = "that"
          volumes            = []
        }
        ]
}
```
More options:
- Using dhcp instead of static IP: `fixed_ip           = null`
- Not assigning floating ip: ` assign_floating_ip = false`
- metadata_role role of the instance e.g "Web-server", "Database", "Kubernetes", e.t.c.
- Attaching volumes example:

```hcl
# Single volume
          volumes            = [
                {
                    volume_size       = 50
                }
          ]

# Two volumes
          volumes            = [
                {
                    volume_size       = 100
                },
                {
                    volume_size       = 30
                }
          ]
# You can attach as many as you want
```
