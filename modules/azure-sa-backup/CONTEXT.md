# azure-sa-backup

Owns the backup configuration for an existing storage account: a Recovery Services vault for file shares and a Data Protection vault for blobs.

Terms below are specific to this module. Cross-cutting vocabulary (Firestartr, ghaps,
`config`, CR, module contract, state boundary, composite module) lives in the root
[`CONTEXT.md`](../../CONTEXT.md); [`CONTEXT-MAP.md`](../../CONTEXT-MAP.md) lists the
other contexts.

## Language

**two vault types**:
File-share backup uses a **Recovery Services** vault; blob backup uses a **Data Protection** vault. This module can own both, and they are different Azure services with different policy shapes.
_Avoid_: the vault (say which)

**protection container**:
The registration of the storage account into the Recovery Services vault. A protected file share cannot exist before it.

**operator role assignment**:
The grant that lets each vault read the storage account. Backups fail silently at job time without it.
