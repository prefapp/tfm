# Basic example: Balanced_B1 Managed Redis with private endpoint
# Replace resource names and networking details for your environment.

terraform {
  required_version = ">= 1.7.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.70.0"
    }
  }
}

provider "azurerm" {
  features {}
}

module "managed_redis" {
  source = "../.."

  resource_group = "example-rg"
  subnet_name    = "example-subnet"

  dns_private_zone_name = "privatelink.redisenterprise.cache.azure.net"

  vnet = {
    name                = "example-vnet"
    resource_group_name = "example-network-rg"
  }

  tags_from_rg = false
  tags = {
    environment = "dev"
    example     = "basic"
  }

  managed_redis = {
    name                      = "managed-redis-basic"
    location                  = "westeurope"
    sku_name                  = "Balanced_B1"
    high_availability_enabled = false # Disable HA for dev/test to reduce cost
    public_network_access     = "Disabled"

    default_database = {
      access_keys_authentication_enabled = true # Enable for quick dev access
      client_protocol                    = "Encrypted"
      clustering_policy                  = "OSSCluster"
      eviction_policy                    = "VolatileLRU"
    }
  }

  private_endpoint = {
    name                          = "pe-managed-redis-basic"
    custom_network_interface_name = "pe-managed-redis-basic-nic"
    private_service_connection = {
      is_manual_connection = false
    }
  }
}

output "hostname" {
  value = module.managed_redis.hostname
}

output "port" {
  value = module.managed_redis.default_database_port
}
