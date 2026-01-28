module "azure_event_hub" {
  source = "../../"

  namespace = {
    name                 = "example-namespace"
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

  system_topic = {
    example-topic = {
      name               = "example-system-topic"
      location           = "westeurope"
      topic_type         = "Microsoft.EventHub.namespaces"
      source_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-rg/providers/Microsoft.EventHub/namespaces/example-namespace"
    }
  }

  eventhub = {
    example-hub = {
      name                 = "example-eventhub"
      partition_count      = 2
      message_retention    = 7
      consumer_group_names = ["$Default"]
      auth_rules = [
        {
          name   = "listen"
          listen = true
          send   = false
          manage = false
        }
      ]
      event_subscription = null
      system_topic_name  = "example-system-topic"
    }
  }

  tags_from_rg = false
  tags = {
    environment = "dev"
  }
}

