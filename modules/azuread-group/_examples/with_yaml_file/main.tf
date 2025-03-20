terraform {
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.52.0"
    }

    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.100.0"
    }
  }
}

provider "azuread" {
  tenant_id = "00000000-0000-0000-0000-000000000000" # Use your tenant_id
}

provider "azurerm" {
  client_id = "00000000-0000-0000-0000-000000000000" # Use your client_id
  features {}
}

locals {

  values = yamldecode(file("./values.yaml"))

}


module "azuread-group"{
    
    source = "../.." # Change this to github URL
    
    name = local.values.name
    
    description = "This is a test group"
    
    members = local.values.members
    
    subscription_roles = local.values.subscription_roles 

    management_group_roles = local.values.management_group_roles
    
    directory_roles = local.values.directory_roles
    
    owners = local.values.owners

    pim_maximum_duration_hours = local.values.pim_maximum_duration_hours

    pim_require_justification = local.values.pim_require_justification
}



