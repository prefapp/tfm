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
