# Terraform OpenStack Networking Module

This module creates a private network, subnet, and router in OpenStack and attaches the subnet to the router.

## Usage

```hcl
module "networking" {
  source = "./terraform-openstack-networking"

  network_name       = "my-private-network"
  subnet_name        = "my-private-subnet"
  subnet_cidr        = "192.168.10.0/24"
  external_network_id = "your-external-network-id"
  region             = "RegionOne"
  dns_nameservers    = ["8.8.8.8", "8.8.4.4"]
}
