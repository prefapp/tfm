# Reference module call (illustrative). Adjust source, providers, and all placeholders.
# Based on the historical README "Example usage" plus required fields from variables.tf.

module "vmss" {
  source = "../.." # or git::https://github.com/prefapp/tfm.git//modules/azure-vmss?ref=<version>

  common = {
    resource_group_name = "my-resource-group"
    location            = "eastus"
  }

  tags_from_rg = true
  tags         = {}

  vmss = {
    name = "my-vmss"
    sku  = "Standard_DS2_v2"

    instances              = 3
    admin_username         = "azureuser"
    admin_ssh_key_username = "ssh-user"
    first_public_key       = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAB..."

    eviction_policy     = "Delete"
    secure_boot_enabled = true

    disk_storage_account_type = "Standard_LRS"
    disk_caching              = "ReadWrite"

    upgrade_mode                                                   = "Rolling"
    rolling_upgrade_policy_max_batch_instance_percent              = 20
    rolling_upgrade_policy_max_unhealthy_instance_percent          = 20
    rolling_upgrade_policy_max_unhealthy_upgraded_instance_percent = 20
    rolling_upgrade_policy_pause_time_between_batches              = "PT5M"
    rolling_upgrade_policy_cross_zone_upgrades_enabled             = false
    rolling_upgrade_policy_maximum_surge_instances_enabled         = false
    rolling_upgrade_policy_prioritize_unhealthy_instances_enabled  = false

    image_publisher = "Canonical"
    image_offer     = "UbuntuServer"
    image_sku       = "18.04-LTS"
    image_version   = "latest"

    subnet_name                         = "my-subnet"
    virtual_network_name                = "my-vnet"
    virtual_network_resource_group_name = "my-resource-group"

    network_interface_public_ip_adress_public_ip_prefix_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/my-resource-group/providers/Microsoft.Network/publicIPPrefixes/my-prefix"

    identity_type = "SystemAssigned"

    cloud_init = file("${path.module}/cloud-init.yml")
    run_script = file("${path.module}/init-script.sh")
  }
}
