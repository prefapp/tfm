# `azure-event-hub`

## Overview

Terraform module that creates an **Event Hubs namespace**, one or more **event hubs**, optional **consumer groups** and **authorization rules**, and optionally **Event Grid system topics**, **event subscriptions** (delivering to an event hub endpoint), and a **role assignment** so Event Grid can send data to the hub.

**Prerequisites**

- An existing **resource group** (`namespace.resource_group_name`).
- Appropriate **Azure RBAC** / identity permissions for Event Hubs and Event Grid resources.

**Behaviour notes (as implemented)**

- **`eventhub`** is a map: each key is used internally to tie consumer groups, auth rules, and (when configured) Event Grid resources to a specific hub. Consumer group and auth rule entries are built from `consumer_group_names` and `auth_rules` lists per hub.
- **Event Grid path**: for an `eventhub` entry, if `event_subscription` and `system_topic_name` are both set, the module creates an `azurerm_eventgrid_system_topic_event_subscription` targeting that hub. `system_topic_name` must match a **key** in the `system_topic` map. The module also creates `azurerm_role_assignment` (`Azure Event Hubs Data Sender`) scoped to the hub when `system_topic_name` is set; `principal_id` comes from the system topic’s managed identity (`try(..., null)` in code—ensure the topic exists so assignment is valid).
- **`system_topic`**: pass **`system_topic = {}`** when you do not use Event Grid; the variable is required by the module interface but an empty map disables those resources (`for_each` over `{}`).
- **Tags**: `tags_from_rg` merges resource group tags with `tags` (module tags override on duplicate keys).
- **`locals.virtual_network_rules` / `locals.ip_rules`**: defined from `namespace.ruleset` but **not referenced** elsewhere in this module; network rules are passed directly via `var.namespace.ruleset` into `azurerm_eventhub_namespace`. These locals are redundant implementation leftovers and do not affect the module interface.

## Basic usage

```hcl
module "event_hub" {
  source = "git::https://github.com/prefapp/tfm.git//modules/azure-event-hub?ref=azure-event-hub-v0.1.1"

  tags_from_rg = false
  tags         = { example = "basic" }

  namespace = {
    name                 = "ehns-example"
    location             = "westeurope"
    resource_group_name  = "example-rg"
    sku                  = "Standard"
    capacity             = 1
    auto_inflate_enabled = false
    identity_type        = "SystemAssigned"
    ruleset = {
      default_action                 = "Allow"
      public_network_access_enabled  = true
      trusted_service_access_enabled = true
      virtual_network_rules          = []
      ip_rules                       = []
    }
  }

  system_topic = {}

  eventhub = {
    hub1 = {
      name                 = "events"
      partition_count      = 2
      message_retention    = 1
      consumer_group_names = ["cg1"]
      auth_rules = [
        { name = "listen", listen = true, send = false, manage = false }
      ]
      event_subscription  = null
      system_topic_name   = null
    }
  }
}
```

## Module layout

| Path | Purpose |
|------|---------|
| `main.tf` | Namespace, hubs, consumer groups, auth rules, Event Grid, role assignment |
| `locals.tf` | Tags, flattened consumer groups and auth rules |
| `variables.tf` | Inputs |
| `outputs.tf` | Exported IDs |
| `versions.tf` | Terraform and provider constraints |
| `CHANGELOG.md` | Release history |
| `docs/header.md` | Overview (this file) |
| `docs/footer.md` | Examples and provider links |
| `_examples/basic` | Minimal validate-oriented example |
| `_examples/comprehensive` | Reference YAML |
| `README.md` | Generated content (terraform-docs) |
| `.terraform-docs.yml` | terraform-docs configuration |
