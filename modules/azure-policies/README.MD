
## Example Usage

```yaml

values:
  policy_name: "inherit-rg-tags"
  policy_display_name: "Ensure Resource Groups' Tags are Inherited"
  policy_description: "This policy enforces that all resources inherit the tags applied to their resource group."
  policy_mode: "Indexed"
  tags_to_inherit:
    - "environment"
    - "cost-center"
    - "owner"
  excluded_resource_types:
    - "Microsoft.Compute/virtualMachines"
    - "Microsoft.Storage/storageAccounts"
  assignment_scope: "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  assignment_enforcement_mode: "Default"
  assignment_identity_type: "SystemAssigned"
  remediation_enabled: true
```
