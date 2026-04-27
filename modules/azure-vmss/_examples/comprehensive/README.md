# Comprehensive / legacy-style reference

Files here preserve the **longer examples** that used to live in the module `README.md`, without bloating the terraform-docs output.

- **`module.reference.hcl`** — HCL aligned with the old “Example usage” block (Rolling upgrade, `Standard_DS2_v2`, Ubuntu 18.04 image, `cloud_init` / `run_script` via `file()`), extended with **required** `vmss` fields that the old snippet omitted (subnet, public IP prefix, full rolling policy, etc.).
- **`values.reference.yaml`** — Same information as nested YAML for tools that prefer `yamldecode()` or copy-paste into Terragrunt/values layers.

**Note:** The original README fenced the first block as `yaml` but the content was HCL, and it placed `tags_from_rg` inside `common` (incorrect for this module). The references here use the **correct** layout: `tags_from_rg` next to `common` / `vmss` at the `module` level.

**Convention:** keep large YAML/HCL samples under `_examples/**`, not inside the generated README.
