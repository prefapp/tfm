# azure-sa

Owns a storage account and the containers, shares, queues and tables inside it, plus its network rules and threat protection.

Terms below are specific to this module. Cross-cutting vocabulary (Firestartr, ghaps,
`config`, CR, module contract, state boundary, composite module) lives in the root
[`CONTEXT.md`](../../CONTEXT.md); [`CONTEXT-MAP.md`](../../CONTEXT-MAP.md) lists the
other contexts.

## Language

**network rules**:
The account firewall: default action, allowed subnets and IP ranges. `allowed_subnets` and `additional_allowed_subnet_ids` are two ways to reach the same list — by value and by explicit ID.

**data surface**:
One of the four kinds of storage the module can create — `containers` (blob), `shares` (file), `queues`, `tables`. An account may hold any mix.

**management policy**:
The lifecycle rules that move or expire blobs by age. It is account-wide, not per container. It is not WORM.

**object replication**:
Asynchronous copying of block blobs from a source account to a destination account, using rules that pair source and destination containers. The source needs change feed and versioning; both accounts need versioning.

**immutability policy**:
The WORM (write once, read many) time-based retention. Two scopes: account-wide (`storage_account.immutability_policy`, only settable at account creation) and per container (`containers[*].immutability_policy`, addable at any time). Once `locked`, it cannot be removed and it blocks deletion of the container and the account.

**advanced threat protection**:
The `azurerm_advanced_threat_protection` toggle. It is billed per account and is off unless configured.
