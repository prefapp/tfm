# Illustrative root module: replace resource names, subscription layout, and Redis sizing for your environment.

terraform {
  required_version = ">= 1.7.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.23.0"
    }
  }
}

provider "azurerm" {
  features {}
}

module "redis_cache" {
  source = "../.."

  resource_group = "example-rg"
  subnet_name    = "example-subnet"

  dns_private_zone_name = "privatelink.redis.cache.windows.net"

  vnet = {
    name                = "example-vnet"
    resource_group_name = "example-network-rg"
  }

  tags_from_rg = false
  tags = {
    example = "basic"
  }

  redis = {
    name                          = "redis-example"
    location                      = "westeurope"
    capacity                      = 1
    family                        = "C"
    sku_name                      = "Standard"
    non_ssl_port_enabled          = false
    public_network_access_enabled = false
    minimum_tls_version           = "1.2"
    redis_version                 = 6
  }

  private_endpoint = {
    name                          = "pe-redis-example"
    custom_network_interface_name = "pe-redis-example-nic"
    private_service_connection = {
      is_manual_connection = false
    }
  }
}
