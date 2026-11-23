#!/usr/bin/env bash
set -euo pipefail

fixture="$(cd "$(dirname "${BASH_SOURCE[0]}")/../testing/deletion-guards" && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

export TF_VAR_events_file="$tmp/events"
tofu -chdir="$fixture" init -backend=false -input=false >/dev/null

tofu -chdir="$fixture" apply -auto-approve -input=false -state="$tmp/full.tfstate" >/dev/null
if tofu -chdir="$fixture" destroy -auto-approve -input=false -state="$tmp/full.tfstate" >"$tmp/full-destroy.log" 2>&1; then
  printf '%s\n' 'Expected protected full destroy to fail.' >&2
  exit 1
fi
if [[ -s "$TF_VAR_events_file" ]]; then
  printf 'Protected full destroy deleted a managed resource: %s\n' "$(<"$TF_VAR_events_file")" >&2
  exit 1
fi

: >"$TF_VAR_events_file"
tofu -chdir="$fixture" apply -auto-approve -input=false -state="$tmp/remove-child.tfstate" >/dev/null
if tofu -chdir="$fixture" apply -auto-approve -input=false -state="$tmp/remove-child.tfstate" -var='children={}' >"$tmp/remove-child.log" 2>&1; then
  printf '%s\n' 'Expected protected child removal to fail.' >&2
  exit 1
fi
if [[ -s "$TF_VAR_events_file" ]]; then
  printf '%s\n' 'Protected child removal deleted a managed child.' >&2
  exit 1
fi

: >"$TF_VAR_events_file"
tofu -chdir="$fixture" apply -auto-approve -input=false -state="$tmp/replace-child.tfstate" >/dev/null
if tofu -chdir="$fixture" apply -auto-approve -input=false -state="$tmp/replace-child.tfstate" -var='children={app="replacement-id"}' >"$tmp/replace-child.log" 2>&1; then
  printf '%s\n' 'Expected protected child replacement to fail.' >&2
  exit 1
fi
if [[ -s "$TF_VAR_events_file" ]]; then
  printf '%s\n' 'Protected child replacement deleted the existing managed child.' >&2
  exit 1
fi

: >"$TF_VAR_events_file"
tofu -chdir="$fixture" apply -auto-approve -input=false -state="$tmp/allowed.tfstate" >/dev/null
tofu -chdir="$fixture" apply -auto-approve -input=false -state="$tmp/allowed.tfstate" -var='deletion_protection=false' >/dev/null
tofu -chdir="$fixture" destroy -auto-approve -input=false -state="$tmp/allowed.tfstate" >/dev/null
if [[ "$(sort -u "$TF_VAR_events_file")" != $'child-deleted\ncluster-deleted' ]]; then
  printf '%s\n' 'Unprotected destroy did not delete the child and cluster.' >&2
  exit 1
fi

printf '%s\n' 'Deletion guard lifecycle tests passed.'
