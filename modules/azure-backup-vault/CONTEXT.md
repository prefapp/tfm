# azure-backup-vault

Owns a Data Protection backup vault and the policies and instances that protect disks, blobs, PostgreSQL, MySQL and Kubernetes clusters.

Terms below are specific to this module. Cross-cutting vocabulary (Firestartr, ghaps,
`config`, CR, module contract, state boundary, composite module) lives in the root
[`CONTEXT.md`](../../CONTEXT.md); [`CONTEXT-MAP.md`](../../CONTEXT-MAP.md) lists the
other contexts.

## Language

**policy vs instance**:
A *policy* defines schedule and retention; an *instance* binds one policy to one protected resource. Policies are reusable, instances are not.

**workload family**:
One of the supported pairs — `disk_*`, `blob_*`, `postgresql_*`, `mysql_*`, `kubernetes_*`. Each is an independent list, and a vault may hold any mix.

**vault**:
The `azurerm_data_protection_backup_vault` every policy and instance in this module hangs off. One vault per module instance.
_Avoid_: recovery services vault (a different Azure resource, used by `azure-sa-backup`)
