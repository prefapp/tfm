# Example: With Vault Admin Password

module "linux_vm" {
  source = "../../"

  common = {
    resource_group_name = "vaultpass-rg"
    location            = "westeurope"
  }
  admin_password = {
    key_vault_name      = "vaultpass-vault"
    resource_group_name = "vaultpass-vault-rg"
    secret_name         = "vaultpass-vm-admin-password"
  }
  vm = {
    name       = "vaultpass-vm"
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
    name                = "vaultpass-vm-nic"
    location            = "westeurope"
    resource_group_name = "vaultpass-rg"
    subnet_name         = "default"
    virtual_network_name = "vaultpass-vnet"
    virtual_network_resource_group_name = "vaultpass-rg"
  }
}
