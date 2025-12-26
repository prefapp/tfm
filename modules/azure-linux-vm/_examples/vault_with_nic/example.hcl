# Example: Vault with NIC

module "linux_vm" {
  source = "../../"

  common = {
    resource_group_name = "example-rg"
    location            = "westeurope"
  }
  admin_password = {
    key_vault_name      = "example-vault"
    resource_group_name = "example-vault-rg"
    secret_name         = "linux-vm-admin-password"
  }
  vm = {
    name       = "example-vm"
    size       = "Standard_B2s"
    admin_username = "azureuser"
    source_image_reference = {
      publisher = "Canonical"
      offer     = "ubuntu-20.04-lts"
      sku       = "server"
      version   = "latest"
    }
    os_disk = {
      caching              = "ReadWrite"
      disk_size_gb         = 64
      storage_account_type = "Standard_LRS"
    }
    admin_ssh_key = {
      username   = "azureuser"
      public_key = "<your-ssh-public-key>"
    }
  }
  nic = {
    name                = "example-vm-nic"
    location            = "westeurope"
    resource_group_name = "example-rg"
    subnet_name         = "default"
    virtual_network_name = "example-vnet"
    virtual_network_resource_group_name = "example-rg"
  }
}
