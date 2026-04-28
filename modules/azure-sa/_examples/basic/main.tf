# Replace resource_group_name and storage_account.name (globally unique, lowercase alphanumeric).

terraform {
  required_version = ">= 1.7.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.38.1"
    }
  }
}

provider "azurerm" {
  features {}
}

module "storage" {
  source = "../.."

  resource_group_name = "example-rg"

  tags_from_rg = false
  tags = {
    example = "basic"
  }

  allowed_subnets               = []
  additional_allowed_subnet_ids = []

  storage_account = {
    name                     = "stbasicexample0001"
    account_tier             = "Standard"
    account_replication_type = "LRS"
  }

  network_rules = {
    default_action = "Allow"
  }
}

output "storage_account_id" {
  value = module.storage.id
}
