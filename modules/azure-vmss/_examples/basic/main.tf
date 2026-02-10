// Basic example: Azure Virtual Machine Scale Set (VMSS)

module "azure_vmss" {
  source = "../../"

  common = {
    resource_group_name = "example-rg"
    location            = "westeurope"
  }

  vmss = {
    name                   = "example-vmss"
    sku                    = "Standard_DS2_v2"
    instances              = 2
    admin_username         = "azureuser"
    admin_ssh_key_username = "azureuser"
    first_public_key       = "<your-ssh-public-key>"

    disk_storage_account_type = "Standard_LRS"
    disk_caching              = "ReadWrite"

    upgrade_mode                                                   = "Rolling"
    rolling_upgrade_policy_max_batch_instance_percent              = 20
    rolling_upgrade_policy_max_unhealthy_instance_percent          = 20
    rolling_upgrade_policy_max_unhealthy_upgraded_instance_percent = 20
    rolling_upgrade_policy_pause_time_between_batches              = "PT0S"
    rolling_upgrade_policy_cross_zone_upgrades_enabled             = true
    rolling_upgrade_policy_maximum_surge_instances_enabled         = true
    rolling_upgrade_policy_prioritize_unhealthy_instances_enabled  = true

    image_publisher = "Canonical"
    image_offer     = "0001-com-ubuntu-server-jammy"
    image_sku       = "server"
    image_version   = "latest"

    subnet_name                         = "vmss-subnet"
    virtual_network_name                = "example-vnet"
    virtual_network_resource_group_name = "example-rg"

    network_interface_public_ip_adress_public_ip_prefix_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-rg/providers/Microsoft.Network/publicIPPrefixes/example-prefix"

    identity_type = "SystemAssigned"

    cloud_init = "#cloud-config"
    run_script = null
  }

  tags = {
    environment = "dev"
  }
}