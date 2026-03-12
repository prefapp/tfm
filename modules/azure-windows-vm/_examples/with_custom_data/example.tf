# Example: With Custom Data

module "windows_vm" {
  source = "../../"

  common = {
    resource_group_name = "example-resource-group"
    location            = "westeurope"
  }

  vm = {
    name       = "example-vm"
    size       = "Standard_B2s"
    admin_username = "azureuser"
    admin_password = "ExamplePassword123!" # Replace with a secure password
    network_interface_ids = ["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-group/providers/Microsoft.Network/networkInterfaces/example-nic"] # Replace with the actual NIC resource ID or reference
    source_image_reference = {
      publisher = "MicrosoftWindowsServer"
      offer     = "WindowsServer"
      sku       = "2019-Datacenter"
      version   = "latest"
    }
    os_disk = {
      caching              = "ReadWrite"
      disk_size_gb         = 64
      storage_account_type = "Standard_LRS"
    }
    # Example: Use a PowerShell script for custom_data
    # custom_data = file("${path.module}/example-init.ps1")

    # Or inline PowerShell script:
    custom_data = <<EOF
      <powershell>
      Write-Output "Hello from example custom_data!"
      </powershell>
      EOF
  }
}
