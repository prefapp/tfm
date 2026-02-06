// Basic example: create a single Azure Resource Group

module "azure_resource_group" {
  source = "../../"

  name     = "group_one"
  location = "westeurope"
  tags = {
    environment = "dev"
  }
}

