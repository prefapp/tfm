# Basic example

Creates a resource group, a virtual network with a single subnet (`internal`), and no private DNS zones or peerings. Use it as a starting point or as a reference for the module’s minimal inputs.

## Usage

From this directory:

```bash
terraform init
terraform plan
terraform apply
```

Rename `azurerm_resource_group.this.name` (or the resource group in Azure) if the chosen name is already taken in your subscription.

## Example configuration

See [`main.tf`](./main.tf).
