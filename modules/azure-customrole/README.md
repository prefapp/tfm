## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.7.5 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~= 4.16.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_role_definition](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_definition) | source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | The name of the Role Definition | `string` | n/a | yes |
| assignable_scopes | One or more assignable scopes for this Role Definition. The first one will become de scope at which the Role Definition applies to. | `list(string)` | n/a | yes |
| permissions | A permissions block with possible 'actions', 'data_actions', 'not_actions' and/or 'not_data_actions'. | <pre>object({<br> actions = list(string) (optional)<br> data_actions = list(string) (optional)<br> not_actions = list(string) (optional)<br> not_data_actions = list(string) (optional)<br>})</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_role_definition_id"></a> [role_definition_id](#output\_role\_definition\_id"></a>) | The ID of the Role Definition. |

## Example

### HCL
```hcl
{
    name: "Custom Role"
    assignable_scopes: ["yyy", "zzz"]
    permissions: {
        actions = [
            "Microsoft.Compute/disks/read",
            "Microsoft.Compute/disks/write",
        ]    
        not_actions = [
            "Microsoft.Compute/disks/read",
            "Microsoft.Compute/disks/write",
        ]    
    }
}
```

### Yaml
```yaml
name: "Custom Role"
assignable_scopes: 
  - "yyy"
  - "zzz"
permissions:
  actions:
    - "Microsoft.Compute/disks/read"
    - "Microsoft.Compute/disks/write"
  notActions:
    - "Microsoft.Authorization/*/Delete"
    - "Microsoft.Authorization/*/Write"
```
