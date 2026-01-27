<!-- BEGIN_TF_DOCS -->
# Azure Custom Role Terraform Module

## Overview

Este módulo de Terraform permite crear un rol personalizado (Custom Role) en Azure, especificando acciones, data actions y los ámbitos (scopes) donde se puede asignar.

## Características principales
- Creación de roles personalizados en Azure.
- Definición flexible de acciones, data actions, not actions y not data actions.
- Soporte para múltiples scopes asignables.

## Ejemplo completo de uso

### HCL
```hcl
module "custom_role" {
  source = "./modules/azure-customrole"
  name   = "Custom Role"
  assignable_scopes = ["/subscriptions/xxx", "/subscriptions/yyy"]
  permissions = {
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

### YAML
```yaml
name: "Custom Role"
assignable_scopes:
  - "/subscriptions/xxx"
  - "/subscriptions/yyy"
permissions:
  actions:
    - "Microsoft.Compute/disks/read"
    - "Microsoft.Compute/disks/write"
  notActions:
    - "Microsoft.Authorization/*/Delete"
    - "Microsoft.Authorization/*/Write"
```

## Estructura de archivos

```
.
├── main.tf
├── variables.tf
├── outputs.tf
├── versions.tf
├── README.md
├── CHANGELOG.md
└── docs/
    ├── header.md
    └── footer.md
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.7.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.16.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 4.16.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_role_definition.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_definition) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_assignable_scopes"></a> [assignable\_scopes](#input\_assignable\_scopes) | One or more assignable scopes for this Role Definition. The first one will become de scope at which the Role Definition applies to. | `list(string)` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name of the Role Definition | `string` | n/a | yes |
| <a name="input_permissions"></a> [permissions](#input\_permissions) | A permissions block with possible 'actions', 'data\_actions', 'not\_actions' and/or 'not\_data\_actions'. | <pre>object({<br/>    actions          = optional(list(string), [])<br/>    data_actions     = optional(list(string), [])<br/>    not_actions      = optional(list(string), [])<br/>    not_data_actions = optional(list(string), [])<br/>  })</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | # OUTPUTS SECTION Role Definition Id |

---

## Recursos adicionales

- [Azure Custom Roles](https://learn.microsoft.com/en-us/azure/role-based-access-control/custom-roles)
- [Proveedor Terraform AzureRM - azurerm\_role\_definition](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_definition)
- [Documentación oficial de Terraform](https://www.terraform.io/docs)

## Soporte

Para dudas, incidencias o contribuciones, utiliza el issue tracker del repositorio: [https://github.com/prefapp/tfm/issues](https://github.com/prefapp/tfm/issues)
<!-- END_TF_DOCS -->