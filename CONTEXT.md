# TFM Context

Shared vocabulary for the `prefapp/tfm` Terraform modules monorepo. This is a glossary of terms specific to how these modules are built and consumed — not a spec and not a place for implementation details.

## Language

**Firestartr**:
The provisioning system that consumes these Terraform modules directly to reconcile desired state from Kubernetes custom resources.
_Avoid_: CDKTF (legacy history only)

**ghaps**:
GitHub Automated Provisioning System — a class of consumer (e.g. `gh-provisioner`) that feeds GitHub modules a single generated config document.
_Avoid_: provisioner (ambiguous)

**config**:
The single top-level Terraform input `object` a ghaps-compatible module accepts, supplied as the sole root key of a generated `terraform.tfvars.json`.
_Avoid_: vars, inputs, tfvars

**CR**:
A Firestartr Kubernetes custom resource describing desired state. A ghaps-compatible module maps to exactly one CR.
_Avoid_: resource (ambiguous with Terraform resources), entity

**module contract**:
The compatibility guarantee that one ghaps module ↔ one CR ↔ one Terraform state ↔ one `terraform.tfvars.json`.
_Avoid_: interface, API

**state boundary**:
The rule that one module owns exactly one Terraform state; several Terraform resources representing one CR compose inside that single module.
_Avoid_: state split, backend

**composite module**:
The pattern used when one CR needs several independently managed artifacts (e.g. `github-files-set`, `github-org-rulesets`).
_Avoid_: multi-module, umbrella module
