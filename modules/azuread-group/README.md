<!-- BEGIN_TF_DOCS -->
# Azure AD Group Module

This Terraform module creates and manages Azure Active Directory (AD) groups, including role assignments, PIM (Privileged Identity Management), owners, and members. It supports configuration via YAML for easier management and reproducibility.

## Requirements
- Terraform >= 1.7.0
- Provider azuread ~> 2.52.0
- Provider azurerm = 4.16.0

### Provisioner actor and permissions

> The provisioner actor must be a Service Principal due to a bug in the provider. See [issue #1386](https://github.com/hashicorp/terraform-provider-azuread/issues/1386).

To make it work, you need to grant permissions to the Service Principal using a PowerShell console as a Global Administrator. Example scripts:

**1. PrivilegedAssignmentSchedule.ReadWrite.AzureADGroup**
```powershell
$TenantID="<your-tenant-id>"

$GraphAppId = "00000003-0000-0000-c000-000000000000"

$MSI="<your-service-principal-object-id>"

$PermissionName = "PrivilegedAssignmentSchedule.ReadWrite.AzureADGroup"

# Install the module

Install-Module AzureAD

Connect-AzureAD -TenantId $TenantID

$GraphServicePrincipal = Get-AzureADServicePrincipal -Filter "appId eq '$GraphAppId'"

$AppRole = $GraphServicePrincipal.AppRoles | Where-Object {$_.Value -eq $PermissionName -and $_.AllowedMemberTypes -contains "Application"}; New-AzureAdServiceAppRoleAssignment -ObjectId $MSI -PrincipalId $MSI -ResourceId $GraphServicePrincipal.ObjectId -Id $AppRole.Id
```
**2. RoleManagementPolicy.ReadWrite.AzureADGroup**
```powershell
$TenantID="<your-tenant-id>"

$GraphAppId = "00000003-0000-0000-c000-000000000000"

$MSI="<your-service-principal-object-id>"

$PermissionName = "RoleManagementPolicy.ReadWrite.AzureADGroup"

# Install the module

Install-Module AzureAD

Connect-AzureAD -TenantId $TenantID

$GraphServicePrincipal = Get-AzureADServicePrincipal -Filter "appId eq '$GraphAppId'"

$AppRole = $GraphServicePrincipal.AppRoles | Where-Object {$_.Value -eq $PermissionName -and $_.AllowedMemberTypes -contains "Application"}; New-AzureAdServiceAppRoleAssignment -ObjectId $MSI -PrincipalId $MSI -ResourceId $GraphServicePrincipal.ObjectId -Id $AppRole.Id
```

**3. PrivilegedEligibilitySchedule.ReadWrite.AzureADGroup**
```powershell
$TenantID="<your-tenant-id>"

$GraphAppId = "00000003-0000-0000-c000-000000000000"

$MSI="<your-service-principal-object-id>"

$PermissionName = "PrivilegedEligibilitySchedule.ReadWrite.AzureADGroup"

# Install the module

Install-Module AzureAD

Connect-AzureAD -TenantId $TenantID

$GraphServicePrincipal = Get-AzureADServicePrincipal -Filter "appId eq '$GraphAppId'"

$AppRole = $GraphServicePrincipal.AppRoles | Where-Object {$_.Value -eq $PermissionName -and $_.AllowedMemberTypes -contains "Application"}; New-AzureAdServiceAppRoleAssignment -ObjectId $MSI -PrincipalId $MSI -ResourceId $GraphServicePrincipal.ObjectId -Id $AppRole.Id
```

## Features
- Create Azure AD groups with custom name and description
- Assign directory and subscription roles
- Manage group owners and members (users, service principals)
- Enable and configure PIM for groups
- YAML-driven configuration for scalable examples

## Minimal usage example

**values.yaml**
```yaml
name: example-group-1
description: Minimal test group
members:
  - type: user
    email: user-2@example.com
```

**main.tf**
```hcl
locals {
  values = yamldecode(file("./values.yaml"))
}

module "azuread-group" {
  source = "../.."
  name   = local.values.name
  description = local.values.description
  members = local.values.members
}
```

> For a complete working example, see the `_examples/with_yaml_file` folder in this repository.

## Known issues
- Removing a `azuread_privileged_access_group_eligibility_schedule` resource may crash the provider ([issue #1399](https://github.com/hashicorp/terraform-provider-azuread/issues/1399)).
- Updating a `azuread_privileged_access_group_eligibility_schedule` may show a wrong log error; sometimes you must remove and recreate the resource ([issue #1412](https://github.com/hashicorp/terraform-provider-azuread/issues/1412)).

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.7.0 |
| <a name="requirement_azuread"></a> [azuread](#requirement\_azuread) | ~> 2.52.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | = 4.16.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azuread"></a> [azuread](#provider\_azuread) | ~> 2.52.0 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | = 4.16.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azuread_directory_role_assignment.this](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/directory_role_assignment) | resource |
| [azuread_group.this](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/group) | resource |
| [azuread_group_member.this](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/group_member) | resource |
| [azuread_group_role_management_policy.members](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/group_role_management_policy) | resource |
| [azuread_group_role_management_policy.owners](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/group_role_management_policy) | resource |
| [azuread_privileged_access_group_assignment_schedule.members](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/privileged_access_group_assignment_schedule) | resource |
| [azuread_privileged_access_group_assignment_schedule.owners](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/privileged_access_group_assignment_schedule) | resource |
| [azuread_privileged_access_group_eligibility_schedule.members](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/privileged_access_group_eligibility_schedule) | resource |
| [azuread_privileged_access_group_eligibility_schedule.owners](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/privileged_access_group_eligibility_schedule) | resource |
| [azurerm_role_assignment.this](https://registry.terraform.io/providers/hashicorp/azurerm/4.16.0/docs/resources/role_assignment) | resource |
| [azuread_directory_roles.current](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/directory_roles) | data source |
| [azuread_groups.members_from_display_names](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/groups) | data source |
| [azuread_groups.members_from_object_ids](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/groups) | data source |
| [azuread_groups.owners_from_display_names](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/groups) | data source |
| [azuread_groups.owners_from_object_ids](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/groups) | data source |
| [azuread_service_principals.members_from_display_name](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/service_principals) | data source |
| [azuread_service_principals.members_from_object_ids](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/service_principals) | data source |
| [azuread_service_principals.owners_from_display_name](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/service_principals) | data source |
| [azuread_service_principals.owners_from_object_ids](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/service_principals) | data source |
| [azuread_users.members_from_emails](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/users) | data source |
| [azuread_users.members_from_object_ids](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/users) | data source |
| [azuread_users.owners_from_emails](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/users) | data source |
| [azuread_users.owners_from_object_ids](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/users) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_assignable_to_role"></a> [assignable\_to\_role](#input\_assignable\_to\_role) | Indicates if the group is assignable to a role | `bool` | `true` | no |
| <a name="input_default_pim_duration"></a> [default\_pim\_duration](#input\_default\_pim\_duration) | The default duration for PIM role assignments | `string` | `"12"` | no |
| <a name="input_description"></a> [description](#input\_description) | The description of the Azure AD group | `string` | n/a | yes |
| <a name="input_directory_roles"></a> [directory\_roles](#input\_directory\_roles) | The list of directory roles to assign to the group | <pre>list(object({<br/>    role_name = string<br/>  }))</pre> | n/a | yes |
| <a name="input_enable_pim"></a> [enable\_pim](#input\_enable\_pim) | Enable Privileged Identity Management (PIM) for the group | `bool` | `false` | no |
| <a name="input_expiration_required"></a> [expiration\_required](#input\_expiration\_required) | Indicates if the expiration is required for the PIM eligible role assignments | `bool` | `false` | no |
| <a name="input_members"></a> [members](#input\_members) | The list of Azure AD users, groups or service principals to assign to the group | <pre>list(object({<br/>    type         = string<br/>    email        = optional(string)<br/>    display_name = optional(string)<br/>    object_id    = optional(string)<br/>    pim = optional(object({<br/>      type                 = optional(string)<br/>      expiration_hours     = optional(string)<br/>      permanent_assignment = optional(bool)<br/>      }),<br/>      {<br/>        type                 = "disabled"<br/>        permanent_assignment = false<br/>    })<br/>  }))</pre> | `[]` | no |
| <a name="input_name"></a> [name](#input\_name) | The name of the Azure AD group | `string` | n/a | yes |
| <a name="input_owners"></a> [owners](#input\_owners) | The list of Azure AD users or service principal owners of the group | <pre>list(object({<br/>    type         = string<br/>    email        = optional(string)<br/>    display_name = optional(string)<br/>    object_id    = optional(string)<br/>    pim = optional(object({<br/>      type                 = optional(string)<br/>      expiration_hours     = optional(string)<br/>      permanent_assignment = optional(bool)<br/>      }),<br/>      {<br/>        expiration_hours     = null<br/>        type                 = "disabled"<br/>        permanent_assignment = false<br/>    })<br/>  }))</pre> | `[]` | no |
| <a name="input_pim_maximum_duration_hours"></a> [pim\_maximum\_duration\_hours](#input\_pim\_maximum\_duration\_hours) | The maximum duration for PIM role assignments | `string` | `"8"` | no |
| <a name="input_pim_require_justification"></a> [pim\_require\_justification](#input\_pim\_require\_justification) | Indicates if the justification is required for the eligible PIM role assignments | `bool` | `true` | no |
| <a name="input_subscription"></a> [subscription](#input\_subscription) | The subscription id | `string` | `null` | no |
| <a name="input_subscription_roles"></a> [subscription\_roles](#input\_subscription\_roles) | The list of built-in roles to assign to the group | <pre>list(object({<br/>    role_name        = string<br/>    resources_scopes = list(string)<br/>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_group_id"></a> [group\_id](#output\_group\_id) | n/a |

## Examples

For detailed examples, refer to the [module examples](https://github.com/prefapp/tfm/tree/main/modules/azuread-group/_examples):

- [basic](https://github.com/prefapp/tfm/tree/main/modules/azuread-group/_examples) - Example showing group creation, members and PIM configuration.

## Resources
- [Terraform AzureAD Provider: group](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/group)
- [Terraform AzureAD Provider: privileged access group](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/privileged_access_group_assignment_schedule)

## Support
For issues, questions, or contributions related to this module, please visit the [repository's issue tracker](https://github.com/prefapp/tfm/issues).
<!-- END_TF_DOCS -->