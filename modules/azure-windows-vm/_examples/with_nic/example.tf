# Example: Vault with NIC

module "windows_vm" {
  source = "../../"

  common = {
    resource_group_name = "example-rg"
    location            = "westeurope"
  }
  vm = {
    name       = "example-vm"
    size       = "Standard_B2s"
    admin_username = "azureuser"
    admin_password = "ChangeMe123!" # Replace with a secure password
    source_image_reference = {
      publisher = "Canonical"
      offer     = "WindowsServer"
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
    subnet_name         = "default"
    virtual_network_name = "example-vnet"
    virtual_network_resource_group_name = "example-rg"
  }
}
