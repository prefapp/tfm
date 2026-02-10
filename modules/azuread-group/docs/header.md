# Azure AD Group Module

This Terraform module creates and manages Azure Active Directory (AD) groups, including role assignments, PIM (Privileged Identity Management), owners, and members. It supports configuration via YAML for easier management and reproducibility.


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
directory_roles: []
subscription_roles: []
```

**main.tf**
```hcl
locals {
  values = yamldecode(file("./values.yaml"))
}

module "azuread-group" {
  source = "../.."
  name              = local.values.name
  description       = local.values.description
  members           = local.values.members
  directory_roles   = local.values.directory_roles
  subscription_roles = local.values.subscription_roles
}
```

> For a more complete example configuration, see the `_examples/with_yaml_file` folder in this repository. Ensure that provider versions in the example align with the Requirements section above.
## Known issues
- Removing a `azuread_privileged_access_group_eligibility_schedule` resource may crash the provider ([issue #1399](https://github.com/hashicorp/terraform-provider-azuread/issues/1399)).
- Updating a `azuread_privileged_access_group_eligibility_schedule` may show a wrong log error; sometimes you must remove and recreate the resource ([issue #1412](https://github.com/hashicorp/terraform-provider-azuread/issues/1412)).