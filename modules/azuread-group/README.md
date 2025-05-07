## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.7.0 |
| <a name="requirement_azuread"></a> [azuread](#requirement\_azuread) | ~> 2.52.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | = 4.16.0 |

### Provisioner actor and permissions

The provisioner actor must be a Service Principal due to a bug in the provider. For more details, check this [issue](https://github.com/hashicorp/terraform-provider-azuread/issues/1386).

To make it work, you need to grant permissions to the Service Principal using a PowerShell console. You can open a terminal in the Azure console panel.

![image](https://github.com/prefapp/tfm/assets/91343444/5096b774-1cc9-4ab2-88c1-0d246d916955)

To execute the following scripts, you should act as Global Administrator.

Execute the following scripts in the powershell terminal.

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

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azuread"></a> [azuread](#provider\_azuread) | ~> 2.52.0 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | = 4.16.0 |

## Resources

| Name | Type |
|------|------|
| [azuread_directory_role_assignment.this](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/directory_role_assignment) | resource |
| [azuread_group.this](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/group) | resource |
| [azuread_group_role_management_policy.members](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/group_role_management_policy) | resource |
| [azuread_group_role_management_policy.owners](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/group_role_management_policy) | resource |
| [azuread_privileged_access_group_assignment_schedule.members](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/privileged_access_group_assignment_schedule) | resource |
| [azuread_privileged_access_group_assignment_schedule.owners](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/privileged_access_group_assignment_schedule) | resource |
| [azuread_privileged_access_group_eligibility_schedule.members](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/privileged_access_group_eligibility_schedule) | resource |
| [azuread_privileged_access_group_eligibility_schedule.owners](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/privileged_access_group_eligibility_schedule) | resource |
| [azurerm_role_assignment.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
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
| <a name="input_enable_pim"></a> [enable\_pim](#input\_enable\_pim) | Enable PIM for groups | `bool` | `false` | no |
| <a name="input_default_pim_duration"></a> [default\_pim\_duration](#input\_default\_pim\_duration) | The default duration for PIM role assignments | `string` | `"12"` | no |
| <a name="input_description"></a> [description](#input\_description) | The description of the Azure AD group | `string` | n/a | yes |
| <a name="input_directory_roles"></a> [directory\_roles](#input\_directory\_roles) | The list of directory roles to assign to the group | <pre>list(object({<br>    <br>        role_name = string<br>    <br>    }))</pre> | n/a | yes |
| <a name="input_expiration_required"></a> [expiration\_required](#input\_expiration\_required) | Indicates if the expiration is required for the PIM eligible role assignments | `bool` | `false` | no |
| <a name="input_members"></a> [members](#input\_members) | The list of Azure AD users, groups or service principals to assign to the group | <pre>list(object({<br>    <br>        type              = string<br>    <br>        email             = optional(string)<br><br>        display_name      = optional(string)<br>    <br>        object_id         = optional(string)<br><br>        pim = optional(object({<br>    <br>            type                 = optional(string)<br>    <br>            expiration_hours     = optional(string)<br><br>            permanent_assignment = optional(bool)<br>        }),<br>        {<br>            type                = "disabled"<br><br>            permanent_assignment = false<br>        })<br>    }))</pre> | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name of the Azure AD group | `string` | n/a | yes |
| <a name="input_owners"></a> [owners](#input\_owners) | The list of Azure AD users or service principal owners of the group | <pre>list(object({<br>    <br>        type                = string<br>        <br>        email               = optional(string)<br><br>        display_name        = optional(string)<br><br>        object_id           = optional(string)<br><br>        pim = optional(object({<br><br>            type                 = optional(string)<br><br>            expiration_hours     = optional(string)<br><br>            permanent_assignment = optional(bool)<br><br>        }), <br>        {<br>            expiration_hours     = null<br><br>            type                 = "disabled"<br>            <br>            permanent_assignment = false<br><br>        })<br>    <br>    }))</pre> | `[]` | no |
| <a name="input_pim_maximum_duration_hours"></a> [pim\_maximum\_duration\_hours](#input\_pim\_maximum\_duration\_hours) | The maximum duration for PIM role assignments | `string` | `"8"` | no |
| <a name="input_pim_require_justification"></a> [pim\_require\_justification](#input\_pim\_require\_justification) | Indicates if the justification is required for the eligible PIM role assignments | `bool` | `true` | no |
| <a name="input_subscription"></a> [subscription](#input\_subscription) | The subscription id | `string` | `null` | no |
| <a name="input_subscription_roles"></a> [subscription\_roles](#input\_subscription\_roles) | The list of built-in roles to assign to the group | <pre>list(object({<br>    <br>      role_name      = string<br>        <br>      resources_scopes = list(string)<br>    <br>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_group_id"></a> [group\_id](#output\_group\_id) | group id |

### Known issues

1. Sometimes, if you try to remove a `azuread_privileged_access_group_eligibility_schedule` resource, the provider crashes, we are waiting for a fix. Check the [issue](https://github.com/hashicorp/terraform-provider-azuread/issues/1399).
2. If you want to update a `azuread_privileged_access_group_eligibility_schedule`, the provider shows a wrong log error. You should remove from terraform the resource and then recreate it. But sometimes has conflicts with the previous point. Check the [issue](https://github.com/hashicorp/terraform-provider-azuread/issues/1412).
