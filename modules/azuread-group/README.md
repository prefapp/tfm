<!-- BEGIN_TF_DOCS -->
# Azure AD group Terraform module

## Overview

This Terraform module creates a **Microsoft Entra ID (Azure AD) security group** and wires it to **subscription (Azure RBAC) role assignments**, **directory (tenant) role assignments**, optional **Privileged Identity Management (PIM)** for members and owners, and **group access policies** when PIM is enabled. It uses the **AzureAD** provider for Entra objects and the **AzureRM** provider for subscription-scoped `azurerm_role_assignment`.

Use it when you want one place to declare group metadata, membership resolution (by email, display name, or object ID), owners, and role bindings aligned with automation and governance patterns.

## Key features

- **Group lifecycle**: Creates `azuread_group` (security-enabled, optionally role-assignable) and explicit `azuread_group_member` entries from resolved principals.
- **Azure RBAC**: Flattens `subscription_roles` into `azurerm_role_assignment` per scope in `resources_scopes`.
- **Directory roles**: Assigns Entra directory roles to the group via `azuread_directory_role_assignment`.
- **PIM (optional)**: When `enable_pim` is true, manages eligible and active assignment schedules and role management policies for members and owners (see variables for duration and justification settings).
- **Flexible principals**: Data sources resolve members and owners from emails, display names, or object IDs for users, groups, and service principals.

## Basic usage

Configure providers in your root module (`azuread` and `azurerm` with `features {}` as required). Pass at least `name`, `description`, `subscription_roles`, and `directory_roles`. The `members` and `owners` inputs are optional and default to empty lists, so you only need to set them when you want to add explicit members or owners. Role lists can be empty when you truly want no subscription or directory role assignments.

### Minimal example

```hcl
module "azuread_group" {
  source = "git::https://github.com/prefapp/tfm.git//modules/azuread-group?ref=<version>"

  name        = "example-security-group"
  description = "Example group managed by Terraform"

  members  = []
  owners   = []

  subscription_roles = []
  directory_roles    = []

  enable_pim = false
}
```

For a fuller configuration driven by YAML, see `_examples/with_yaml_file`.

## Provisioner actor and permissions

The provisioner actor must be a **service principal** due to a limitation in the AzureAD provider; see [terraform-provider-azuread#1386](https://github.com/hashicorp/terraform-provider-azuread/issues/1386).

Grant the required Microsoft Graph **application** permissions to that service principal using PowerShell (e.g. from Azure Cloud Shell). You need to act as a **Global Administrator** to run the assignments below.

![PowerShell permission assignment reference](https://github.com/prefapp/tfm/assets/91343444/5096b774-1cc9-4ab2-88c1-0d246d916955)

Execute the following in order.

### 1. PrivilegedAssignmentSchedule.ReadWrite.AzureADGroup

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

### 2. RoleManagementPolicy.ReadWrite.AzureADGroup

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

### 3. PrivilegedEligibilitySchedule.ReadWrite.AzureADGroup

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

## File structure

```
.
├── CHANGELOG.md
├── data_members.tf
├── data_owners.tf
├── directory_roles.tf
├── group_policy.tf
├── locals_members.tf
├── locals_owners.tf
├── main.tf
├── outputs.tf
├── pim_active.tf
├── pim_eligible.tf
├── subscription_roles.tf
├── variables.tf
├── versions.tf
├── docs
│   ├── footer.md
│   └── header.md
├── _examples
│   ├── basic
│   └── with_yaml_file
├── README.md
└── .terraform-docs.yml
```

- **`main.tf`**: `azuread_group` and `azuread_group_member`.
- **`data_members.tf` / `data_owners.tf`**: Data sources to resolve member and owner object IDs.
- **`locals_members.tf` / `locals_owners.tf`**: Local logic for direct members, owners, and PIM-related sets.
- **`subscription_roles.tf`**: Azure RBAC role assignments on Azure scopes.
- **`directory_roles.tf`**: Entra directory role assignments to the group.
- **`pim_eligible.tf` / `pim_active.tf`**: PIM eligibility and active schedules when enabled.
- **`group_policy.tf`**: Group role management policies when PIM is enabled.
- **`variables.tf` / `outputs.tf` / `versions.tf`**: Inputs, outputs, and provider version constraints.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.7.0 |
| <a name="requirement_azuread"></a> [azuread](#requirement\_azuread) | ~> 2.52.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | = 4.16.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azuread"></a> [azuread](#provider\_azuread) | 2.52.0 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.16.0 |

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
| <a name="output_group_id"></a> [group\_id](#output\_group\_id) | Object ID of the Microsoft Entra ID (Azure AD) group created by this module. |

## Examples

For detailed examples, refer to the [module examples](https://github.com/prefapp/tfm/tree/main/modules/azuread-group/_examples):

- [basic](https://github.com/prefapp/tfm/tree/main/modules/azuread-group/_examples/basic) — Minimal module call with empty role lists (adjust for your tenant).
- [with\_yaml\_file](https://github.com/prefapp/tfm/tree/main/modules/azuread-group/_examples/with\_yaml\_file) — Load `members`, `owners`, and roles from `values.yaml`.

## Remote resources

- **Microsoft Entra ID (Azure AD) groups**: [https://learn.microsoft.com/entra/identity/](https://learn.microsoft.com/entra/identity/)
- **Terraform AzureAD provider**: [https://registry.terraform.io/providers/hashicorp/azuread/latest](https://registry.terraform.io/providers/hashicorp/azuread/latest)
- **Terraform AzureRM provider**: [https://registry.terraform.io/providers/hashicorp/azurerm/latest](https://registry.terraform.io/providers/hashicorp/azurerm/latest)

## Known issues

1. Sometimes, if you try to remove a `azuread_privileged_access_group_eligibility_schedule` resource, the provider crashes; see [terraform-provider-azuread#1399](https://github.com/hashicorp/terraform-provider-azuread/issues/1399).
2. If you want to update a `azuread_privileged_access_group_eligibility_schedule`, the provider may show a misleading error. You may need to remove the resource from Terraform state and recreate it, which can conflict with the previous point; see [terraform-provider-azuread#1412](https://github.com/hashicorp/terraform-provider-azuread/issues/1412).

## Support

For issues, questions, or contributions related to this module, please visit the repository’s issue tracker: [https://github.com/prefapp/tfm/issues](https://github.com/prefapp/tfm/issues)
<!-- END_TF_DOCS -->