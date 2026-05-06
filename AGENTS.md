# TFM Agent Instructions

All AI agents working in this repository must read and follow `CONSTITUTION.md` before proposing or making changes.

## Mandatory Reading

Before any code or documentation change, read:

- `CONSTITUTION.md`
- `CONTRIBUTING.md`
- `RULES.md` when the module is or may be consumed by Firestartr `gh_provisioner`
- Existing files in the target module, especially `variables.tf`, `main.tf`, `outputs.tf`, `versions.tf`, `docs/header.md`, `docs/footer.md`, `_examples/`, and `README.md`

## Repository Purpose

This repository contains Terraform modules. Firestartr now consumes these modules directly. Do not introduce CDKTF guidance for current Firestartr GitHub resource integrations unless a user explicitly asks about legacy history.

## Working Rules

- Strictly follow `CONTRIBUTING.md` for module layout, docs, examples, README generation, commit style, and PR process.
- Prefer small, focused modules with one responsibility.
- Use explicit Terraform object types and validations.
- Keep module inputs and outputs stable for consumers.
- Document import IDs, Terraform resource addresses, and destructive lifecycle behavior.
- Do not weaken existing validations or remove useful outputs without a migration reason.
- Do not bypass `terraform fmt`, validation, tests, docs generation, CI, or release requirements.

## gh-provisioner Modules

For modules consumed by `gh_provisioner`, load and follow `RULES.md`.

The non-negotiable contract is a single top-level `config` input object consumed from `terraform.tfvars.json`. The module must be compatible with one Firestartr CR and one Terraform state.

If a requested module cannot be modeled with that contract, stop and explain why it is not compatible before writing code.

## Expected Agent Output

When proposing or implementing a module change, include:

- The module path.
- Whether it is `gh_provisioner` compatible.
- The `config` shape if applicable.
- Import behavior.
- Delete behavior and any safety concerns.
- Validation performed or intentionally skipped.
