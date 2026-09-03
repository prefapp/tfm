# github-files-set

Owns a set of files inside one GitHub repository, with provision-once semantics for files the user is allowed to edit afterwards.

Terms below are specific to this module. Cross-cutting vocabulary (Firestartr, ghaps,
`config`, CR, module contract, state boundary, composite module) lives in the root
[`CONTEXT.md`](../../CONTEXT.md); [`CONTEXT-MAP.md`](../../CONTEXT-MAP.md) lists the
other contexts.

## Language

**managed file**:
A `config.files` entry — a path on a branch, its content, and the commit message used to write it. `file` + `branch` is the identity, and duplicates are rejected by validation.

**userManaged file**:
A file the module writes **once** and then stops owning, so a human may edit or delete it without Terraform reverting the change. The opposite (`userManaged = false`, the default) is reconciled on every apply.

**installed managed files**:
The accumulated list of `"<file>/<branch>"` addresses already provisioned at least once, passed back in by the caller each reconciliation. It is how *provision-once* survives across applies, since Terraform state alone cannot express it.

**empty file set**:
The legitimate steady state where `config.files` is `[]` while `installed_managed_files` is not: every file is userManaged and already installed. This is why the module does not require a non-empty file list.
_Avoid_: misconfiguration, drift

**overwriteOnCreate**:
Whether writing a file may clobber content that already exists in the repository at that path.
