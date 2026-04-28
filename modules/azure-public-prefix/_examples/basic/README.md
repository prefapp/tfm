# Basic example

Creates one **public IP prefix** via the module. Set a real resource group and adjust `prefix_length` / `zones` per [Azure constraints](https://learn.microsoft.com/azure/virtual-network/ip-services/public-ip-address-prefix) and your region.

```bash
terraform init
terraform plan
```

See [`main.tf`](./main.tf).
