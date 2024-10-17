# WIP

```yaml
resource_group_name: "bk-disks"
location: "West Europe"
vault_name: "bk-disks"
datastore_type: "VaultStore"
redundancy: "LocallyRedundant"
soft_delete: "Off"
backup_policies:
  - name: "foo-policy"
    backup_repeating_time_intervals:
      - "R/2024-10-17T11:29:40+00:00/PT1H"
    default_retention_duration: "P7D"
    time_zone: "Coordinated Universal Time"
    retention_rules:
      - name: "Daily"
        duration: "P7D"
        priority: 25
        criteria:
          absolute_criteria: "FirstOfDay"
  - name: "bar-policy"
    backup_repeating_time_intervals:
      - "R/2024-11-01T10:00:00+00:00/PT2H"
    default_retention_duration: "P14D"
    time_zone: "Pacific Standard Time"
    retention_rules:
      - name: "Weekly"
        duration: "P14D"
        priority: 30
        criteria:
          absolute_criteria: "FirstOfWeek"
backup_instances:
  - disk_name: "foo-disk"
    disk_resource_group: "foo-data"
    snapshot_resource_group_name: "bk-disks"
    backup_policy_name: "foo-policy"
  - disk_name: "foo-disk"
    disk_resource_group: "foo-data"
    snapshot_resource_group_name: "bk-disks"
    backup_policy_name: "foo-policy"
  - disk_name: "bar-disk"
    disk_resource_group: "bar-data"
    snapshot_resource_group_name: "bk-disks"
    backup_policy_name: "bar-policy"
```
