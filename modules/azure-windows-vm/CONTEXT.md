# azure-windows-vm

Owns one Windows virtual machine and its network interface.

Terms below are specific to this module. Cross-cutting vocabulary (Firestartr, ghaps,
`config`, CR, module contract, state boundary, composite module) lives in the root
[`CONTEXT.md`](../../CONTEXT.md); [`CONTEXT-MAP.md`](../../CONTEXT-MAP.md) lists the
other contexts.

## Language

**common**:
The `common` object carrying the resource group and location every resource in the module shares.

**admin password source**:
Either supplied inline or, when `admin_password.key_vault_name` is set, read from an existing Key Vault secret. The module reads the secret; it never creates it.

**nic**:
The `nic` object — subnet, optional public IP and optional network security group association. Network resources are looked up, not created.
