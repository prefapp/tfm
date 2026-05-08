# TFM Agent Instructions

All AI agents working in this repository must read and follow `CONSTITUTION.md` before proposing or making changes.

## Mandatory Reading

Before any code or documentation change, read:

- `CONSTITUTION.md`
- `CONTRIBUTING.md`
- `RULES.md` when the module is or may be a GitHub module compatible with GitHub Automated Provisioning Systems such as `ghaps`
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

## ghaps Modules

For GitHub modules consumed by GitHub Automated Provisioning Systems such as `ghaps`, load and follow `RULES.md`.

The non-negotiable contract is a single top-level `config` input object consumed from `terraform.tfvars.json`. The module must be compatible with one Firestartr CR and one Terraform state.

If a requested module cannot be modeled with that contract, stop and explain why it is not compatible before writing code.

## Expected Agent Output

When proposing or implementing a module change, include:

- The module path.
- Whether it is compatible with GitHub Automated Provisioning Systems such as `ghaps`.
- The `config` shape if applicable.
- Import behavior.
- Delete behavior and any safety concerns.
- Validation performed or intentionally skipped.
- Path to the `tasks.md` used for this PR and status of each task.

## Spec-Driven Development (Mandatory for All Agents)

Before any module change:

1. Locate or create the correct folder under `specs/<module-name>/`
2. Read the current `spec.md`, `plan.md`, and `tasks.md`
3. Work **only** on the tasks listed in the current `tasks.md`
4. Update `tasks.md` as you complete each task (keep it in the PR)

**Never** propose code changes without a corresponding `tasks.md` entry.

### Specification Location Rules (strict)
- Use exactly: `specs/<module-name>/NNN-feature-slug/`
- Module name **must** match the folder inside `modules/` (e.g. `aws-eks`, `azure-vpc`, `github-team`)
- For changes spanning multiple modules → use `specs/cross-module/`
- All three files (`spec.md`, `plan.md`, `tasks.md`) **must stay** in the repository after merge.

When creating a new task file, follow the template from specdriven.ai (or the existing pattern already used in this repo).

## Critical Safety Rules (Highest Priority)

### Changelog Protection (Automated Release System)
- The repository uses Release Please to manage all `CHANGELOG.md` files automatically.
- **AI agents are strictly forbidden** from touching, creating, modifying, or proposing any changes to any `CHANGELOG.md` file (root or per-module).
- If a task seems to require changelog changes, the AI must skip it and note: “Changelog will be updated by Release Please automation”.
- This rule overrides every other instruction.
