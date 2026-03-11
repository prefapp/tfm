## Examples

For detailed examples, refer to the [module examples](https://github.com/prefapp/tfm/tree/main/modules/azure-vnet-gateway/_examples):

- [basic_route_based](https://github.com/prefapp/tfm/tree/main/modules/azure-vnet-gateway/_examples/basic_route_based) - Basic RouteBased gateway example.
- [active_active_bgp](https://github.com/prefapp/tfm/tree/main/modules/azure-vnet-gateway/_examples/active_active_bgp) - Active-Active gateway with BGP enabled.
- [vpn_client_aad](https://github.com/prefapp/tfm/tree/main/modules/azure-vnet-gateway/_examples/vpn_client_aad) - Gateway with VPN Client and Azure AD authentication.
- NAT rule example:

```hcl
nat_rules = [
  {
    name = "egress-nat"
    mode = "EgressSnat"
    type = "Static"
    external_mapping_address_space = "203.0.113.0/24"
    internal_mapping_address_space = "10.0.0.0/24"
  }
]
```

## Remote resources

- **Azure Virtual Network Gateway**: [azurerm_virtual_network_gateway documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_gateway)
- **NAT Rule**: [azurerm_virtual_network_gateway_nat_rule documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_gateway_nat_rule)
- **Terraform Azure Provider**: [Terraform Provider documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)

## Support

For issues, questions, or contributions related to this module, please visit the [repository's issue tracker](https://github.com/prefapp/tfm/issues).
