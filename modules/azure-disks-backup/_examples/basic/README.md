# Basic example — `azure-disks-backup`

Creates a resource group, a Data Protection backup vault, policies, and backup instances for disks you reference by name.

Before `terraform apply`, create the **managed disks** (and their resource groups) referenced in `backup_instances`, or adjust the example to match your environment. Configure the `azurerm` provider (subscription, authentication) as usual.
