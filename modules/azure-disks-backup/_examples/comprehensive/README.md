# Comprehensive reference — `azure-disks-backup`

`values.reference.yaml` shows multiple **backup policies** and **backup instances** with realistic schedule and retention shapes.

This directory is documentation only unless you copy values into your own root module. Remember: **`disk_name`** values must be **unique** in `backup_instances`, and **snapshot storage** uses the vault’s **`resource_group_name`** (not a field on each instance).
