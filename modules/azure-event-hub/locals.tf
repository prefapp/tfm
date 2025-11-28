locals {
  # Handle tags based on whether to use resource group tags or module-defined tags
  tags = var.tags_from_rg ? merge(data.azurerm_resource_group.this.tags, var.tags) : var.tags
}

locals {
  consumer_groups = flatten([
    for eh_key, eh_value in var.eventhub : [
      for cg in try(eh_value.consumer_group_names, []) : {
        key         = "${eh_key}.${cg}"
        eventhub_key = eh_key
        name        = cg
      }
    ]
  ])
  authorization_rules = flatten([
    for eh_key, eh_value in var.eventhub : [
      for ar in try(eh_value.auth_rules, []) : {
        key          = "${eh_key}.${ar.name}"
        eventhub_key = eh_key
        name         = ar.name
        listen       = ar.listen
        send         = ar.send
        manage       = ar.manage
      }
    ]
  ])
}
