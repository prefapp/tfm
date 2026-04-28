# Basic example

Skeleton for the `azure-vmss` module. **Do not apply** until you replace:

- Resource group, VNet, and subnet names (and `virtual_network_resource_group_name` if different).
- `network_interface_public_ip_adress_public_ip_prefix_id` with a real public IP prefix in your subscription.
- `first_public_key` with a valid SSH public key.

## Usage

```bash
terraform init
terraform plan
```

## Configuration

See [`main.tf`](./main.tf).
