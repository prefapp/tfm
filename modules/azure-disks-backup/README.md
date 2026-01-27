<!-- BEGIN_TF_DOCS -->
# Azure Disks Backup Terraform Module

## Overview

Este módulo de Terraform permite crear y configurar backups de discos gestionados en Azure, incluyendo:
- Creación de Recovery Services vault.
- Definición de políticas de backup personalizadas.
- Creación de instancias de backup para discos específicos.
- Soporte para etiquetas y herencia desde el Resource Group.

## Características principales
- Vault y políticas de backup configurables.
- Soporte para múltiples discos y políticas.
- Control de retención, redundancia y soft delete.
- Ejemplo realista de configuración.

## Ejemplo completo de uso

```hcl
resource_group_name = "bk-disks"
vault_name          = "bk-disks"
tags_from_rg        = true
tags = {
  Environment = "Production"
  Project     = "Azure Disks Backup"
}
datastore_type      = "VaultStore"
redundancy          = "LocallyRedundant"
soft_delete         = "Off"
retention_duration_in_days = 30
backup_policies = [
  {
    name = "foo-policy"
    backup_repeating_time_intervals = ["R/2024-10-17T11:29:40+00:00/PT1H"]
    default_retention_duration = "P7D"
    time_zone = "Coordinated Universal Time"
    retention_rules = [
      {
        name = "Daily"
        duration = "P7D"
        priority = 25
        criteria = { absolute_criteria = "FirstOfDay" }
      }
    ]
  },
  {
    name = "bar-policy"
    backup_repeating_time_intervals = ["R/2024-11-01T10:00:00+00:00/PT2H"]
    default_retention_duration = "P14D"
    time_zone = "Pacific Standard Time"
    retention_rules = [
      {
        name = "Weekly"
        duration = "P14D"
        priority = 30
        criteria = { absolute_criteria = "FirstOfWeek" }
      },
      {
        name = "Monthly"
        duration = "P30D"
        priority = 35
        criteria = { absolute_criteria = "FirstOfMonth" }
      }
    ]
  }
]
backup_instances = [
  {
    disk_name = "foo-disk"
    disk_resource_group = "foo-data"
    snapshot_resource_group_name = "bk-disks"
    backup_policy_name = "foo-policy"
  },
  {
    disk_name = "foo-disk"
    disk_resource_group = "foo-data"
    snapshot_resource_group_name = "bk-disks"
    backup_policy_name = "bar-policy"
  },
  {
    disk_name = "bar-disk"
    disk_resource_group = "bar-data"
    snapshot_resource_group_name = "bk-disks"
    backup_policy_name = "bar-policy"
  }
]
```

## Notas
- El resource\_group\_name debe ser el mismo para el vault y los snapshots.
- Los discos pueden estar en resource groups diferentes al del vault.
- El módulo lanza error si el resource group del disco y del vault coinciden.

## Estructura de archivos

```
.
├── main.tf
├── variables.tf
├── outputs.tf
├── README.md
├── CHANGELOG.md
└── docs/
    ├── header.md
    └── footer.md
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.7.1 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | 4.5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.5.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_data_protection_backup_instance_disk.this](https://registry.terraform.io/providers/hashicorp/azurerm/4.5.0/docs/resources/data_protection_backup_instance_disk) | resource |
| [azurerm_data_protection_backup_policy_disk.this](https://registry.terraform.io/providers/hashicorp/azurerm/4.5.0/docs/resources/data_protection_backup_policy_disk) | resource |
| [azurerm_data_protection_backup_vault.this](https://registry.terraform.io/providers/hashicorp/azurerm/4.5.0/docs/resources/data_protection_backup_vault) | resource |
| [azurerm_role_assignment.this_disk](https://registry.terraform.io/providers/hashicorp/azurerm/4.5.0/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.this_rg](https://registry.terraform.io/providers/hashicorp/azurerm/4.5.0/docs/resources/role_assignment) | resource |
| [azurerm_managed_disk.this](https://registry.terraform.io/providers/hashicorp/azurerm/4.5.0/docs/data-sources/managed_disk) | data source |
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/4.5.0/docs/data-sources/resource_group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_backup_instances"></a> [backup\_instances](#input\_backup\_instances) | List of backup instances. | <pre>list(object({<br/>    disk_name                    = string<br/>    disk_resource_group          = string<br/>    backup_policy_name           = string<br/>  }))</pre> | n/a | yes |
| <a name="input_backup_policies"></a> [backup\_policies](#input\_backup\_policies) | List of backup policies. | <pre>list(object({<br/>    name                            = string<br/>    backup_repeating_time_intervals = list(string)<br/>    default_retention_duration      = string<br/>    time_zone                       = string<br/>    retention_rules = list(object({<br/>      name     = string<br/>      duration = string<br/>      priority = number<br/>      criteria = object({<br/>        absolute_criteria = string<br/>      })<br/>    }))<br/>  }))</pre> | n/a | yes |
| <a name="input_datastore_type"></a> [datastore\_type](#input\_datastore\_type) | The type of datastore. | `string` | `"VaultStore"` | no |
| <a name="input_redundancy"></a> [redundancy](#input\_redundancy) | The redundancy type. | `string` | `"LocallyRedundant"` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group used for the backup vault and backup instances. | `string` | n/a | yes |
| <a name="input_retention_duration_in_days"></a> [retention\_duration\_in\_days](#input\_retention\_duration\_in\_days) | The retention duration in days before the backup is purged. 14 days free. | `number` | `14` | no |
| <a name="input_soft_delete"></a> [soft\_delete](#input\_soft\_delete) | Enable soft delete. | `string` | `"Off"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to resources | `map(string)` | `{}` | no |
| <a name="input_tags_from_rg"></a> [tags\_from\_rg](#input\_tags\_from\_rg) | Use resource group tags as base for module tags | `bool` | `false` | no |
| <a name="input_vault_name"></a> [vault\_name](#input\_vault\_name) | The name of the backup vault. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_vault_id"></a> [vault\_id](#output\_vault\_id) | n/a |

---

## Recursos adicionales

- [Azure Backup para discos](https://learn.microsoft.com/en-us/azure/backup/backup-managed-disks)
- [azurerm\_data\_protection\_backup\_vault](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_protection_backup_vault)
- [azurerm\_data\_protection\_backup\_policy](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_protection_backup_policy)
- [azurerm\_data\_protection\_backup\_instance\_disk](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_protection_backup_instance_disk)
- [Documentación oficial de Terraform](https://www.terraform.io/docs)

## Soporte

Para dudas, incidencias o contribuciones, utiliza el issue tracker del repositorio: [https://github.com/prefapp/tfm/issues](https://github.com/prefapp/tfm/issues)
<!-- END_TF_DOCS -->