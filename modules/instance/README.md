# Terraform OpenStack Compute Module

This Terraform module is designed for creating and managing OpenStack compute instances, volumes, and floating IPs. It allows you to define instances with attached volumes and optionally assign floating IPs.

## Overview

This module provides:
- Creation of OpenStack compute instances with user-defined properties.
- Creation and attachment of block storage volumes to instances.
- Management of floating IPs and their association with instances.

## Prerequisites

- Terraform (version 1.0 or later)
- Terragrunt (version 0.34 or later)
- OpenStack credentials (authenticated through environment variables or configuration file)

## Inputs

| Name               | Description                                          | Type                   | Default | Required |
|--------------------|------------------------------------------------------|------------------------|---------|----------|
| `instances`        | List of instances to be created                     | `list(map(string))`    | n/a     | yes      |
| `floating_ip_pool` | Pool from which floating IPs will be allocated      | `string`               | n/a     | yes      |

### `instances` Variable

The `instances` variable is a list of maps where each map defines an instance and its properties. Each instance map can contain the following keys:

- `name` (string): Name of the instance.
- `image_id` (string): ID of the image to use for the instance.
- `flavor_id` (string): Flavor ID to define the instance size.
- `key_pair` (string): Name of the key pair to use for SSH access.
- `security_groups` (list(string)): List of security groups to associate with the instance.
- `network_id` (string): Network ID to attach the instance to.
- `fixed_ip` (string, optional): Fixed IP address to assign to the instance.
- `userdata_file` (string, optional): Path to a file containing user data.
- `metadata_role` (string): Metadata role to apply to the instance.
- `volumes` (list(map(string)), optional): List of volumes to attach to the instance.
- `assign_floating_ip` (bool): Whether to assign a floating IP to the instance.

## Example

### Direct Usage

```hcl
module "compute" {
  source = "./path/to/this/module"

  instances = [
    {
      name            = "my-instance"
      image_id        = "your-image-id"
      flavor_id       = "your-flavor-id"
      key_pair        = "your-key-pair"
      security_groups = ["default"]
      network_id      = "your-network-id"
      fixed_ip        = "10.0.0.10"
      userdata_file   = "./userdata.sh"
      metadata_role   = "webserver"
      volumes = [
        {
          volume_size = 20
        }
      ]
      assign_floating_ip = true
    }
  ]

  floating_ip_pool = "public"
}
