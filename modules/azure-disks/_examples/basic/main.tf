// Basic example: create managed disks using the azure-disks module

module "azure_disks" {
  source = "../../"

  location            = "westeurope"
  resource_group_name = "example-rg"

  disks = {
    data1 = {
      # This map is intentionally loose; adapt keys to match main.tf expectations.
      size_gb             = 128
      sku                 = "Premium_LRS"
      zone                = "1"
      create_option       = "Empty"
      encryption_type     = "EncryptionAtRestWithPlatformKey"
      disk_iops_read_write = 500
      disk_mbps_read_write = 100
    }
  }

  assign_role         = false
  role_definition_name = "Contributor"
  principal_id        = ""

  tags = {
    environment = "dev"
    application = "example"
  }
}