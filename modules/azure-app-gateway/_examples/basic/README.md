# Basic usage notes

This module is configured through large structured objects (`application_gateway`, `web_application_firewall_policy`, `public_ip`, `subnet`, etc.) rather than a minimal copy-paste `main.tf`.

Before calling the module, ensure:

- A **resource group** and **subnet** suitable for Application Gateway exist.
- A **user-assigned managed identity** exists in that resource group and can read the **Key Vault secrets** referenced by `application_gateway.ssl_certificates`.
- You understand the **`application_gateway.blocks`** hierarchy used by the `locals_*.tf` files (organization → app → tier → component blocks).

For a full example shape, see [comprehensive/values.reference.yaml](../comprehensive/values.reference.yaml).
