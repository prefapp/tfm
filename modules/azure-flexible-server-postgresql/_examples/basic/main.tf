module "azure_flexible_server_postgresql" {
  source = "../../"

  resource_group = "example-resource-group"
  tags_from_rg   = true

  key_vault = {
    tags = {
      value = "tag1"
    }
  }

  vnet = {
    tags = {
      value = "tag1"
    }
  }

  subnet_name                  = "example-subnet"
  dns_private_zone_name        = "dns.private.zone.example.com"
  administrator_password_key_vault_secret_name = "flexible-server-secret-example-test"
  password_length              = 10

  postgresql_flexible_server = {
    location                      = "westeurope"
    name                          = "example-flexible-server"
    version                       = 15
    administrator_login           = "psqladmin"
    public_network_access_enabled = false
    storage_mb                    = 65536
    sku_name                      = "GP_Standard_D2ds_v5"
    backup_retention_days         = 30
    maintenance_window = {
      day_of_week  = 6
      start_hour   = 0
      start_minute = 0
    }
    authentication = {
      active_directory_auth_enabled = false
      password_auth_enabled         = true
    }
  }

  postgresql_flexible_server_configuration = {
    "azure.extensions" = {
      name  = "azure.extensions"
      value = "extension1,extension2"
    }
    "configuration1" = {
      name  = "example-configuration"
      value = "TRUE"
    }
  }

  firewall_rule = []

  tags = {
    environment = "dev"
  }
}

