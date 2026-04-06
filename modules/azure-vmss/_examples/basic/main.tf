# Replace all placeholders (RG, VNet, subnet, public IP prefix, SSH key) before apply.

terraform {
  required_version = ">= 1.7.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.16.0"
    }
  }
}

provider "azurerm" {
  features {}
}

module "vmss" {
  source = "../.."

  common = {
    resource_group_name = "example-rg"
    location            = "westeurope"
  }

  tags_from_rg = false
  tags = {
    example = "basic"
  }

  vmss = {
    name                   = "example-vmss"
    resource_group_name    = "example-rg"
    sku                    = "Standard_B2s"
    instances              = 1
    admin_username         = "azureuser"
    admin_ssh_key_username = "azureuser"
    first_public_key       = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCplaceholder-replace-with-your-public-key"

    disk_storage_account_type = "Standard_LRS"
    disk_caching              = "ReadWrite"

    upgrade_mode                                                   = "Manual"
    rolling_upgrade_policy_max_batch_instance_percent              = 20
    rolling_upgrade_policy_max_unhealthy_instance_percent          = 20
    rolling_upgrade_policy_max_unhealthy_upgraded_instance_percent = 20
    rolling_upgrade_policy_pause_time_between_batches              = "PT5M"
    rolling_upgrade_policy_cross_zone_upgrades_enabled             = false
    rolling_upgrade_policy_maximum_surge_instances_enabled         = false
    rolling_upgrade_policy_prioritize_unhealthy_instances_enabled  = false

    image_publisher = "Canonical"
    image_offer     = "0001-com-ubuntu-server-jammy"
    image_sku       = "22_04-lts"
    image_version   = "latest"

    subnet_name                         = "example-subnet"
    virtual_network_name                = "example-vnet"
    virtual_network_resource_group_name = "example-rg"

    network_interface_public_ip_adress_public_ip_prefix_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-rg/providers/Microsoft.Network/publicIPPrefixes/example-prefix"

    identity_type = "SystemAssigned"

    cloud_init = "#cloud-config\n"
    run_script = null
  }
}

output "vmss_id" {
  value = module.vmss.vmss_id
}
