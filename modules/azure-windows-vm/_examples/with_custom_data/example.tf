# Example: With Custom Data

module "windows_vm" {
  source = "../../"

  common = {
    resource_group_name = "customdata-rg"
    location            = "westeurope"
  }

  vm = {
    name       = "customdata-vm"
    size       = "Standard_B2s"
    admin_username = "azureuser"
    admin_password = "YourSecurePassword123!" # Replace with a secure password
    nic = "your-nic-id" # Replace with the actual NIC resource ID or reference
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
    custom_data = file("${path.module}/init.ps1")

    # Or inline PowerShell script:
    # custom_data = <<EOF
    # <powershell>
    # Write-Output "Hello from custom_data!"
    # </powershell>
    # EOF
  }
}
