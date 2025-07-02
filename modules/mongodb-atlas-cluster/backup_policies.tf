# https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/resources/cloud_backup_schedule
resource "mongodbatlas_cloud_backup_schedule" "this" {
  project_id   = var.project_id
  cluster_name = mongodbatlas_cluster.this.name

  reference_hour_of_day    = 3
  reference_minute_of_hour = 45
  restore_window_days      = 4

  // This will now add the desired policy items to the existing mongodbatlas_cloud_backup_schedule resource
  policy_item_hourly {
    frequency_interval = 1        #accepted values = 1, 2, 4, 6, 8, 12 -> every n hours
    retention_unit     = "days"
    retention_value    = 1
  }
  policy_item_daily {
    frequency_interval = 1        #accepted values = 1 -> every 1 day
    retention_unit     = "days"
    retention_value    = 2
  }
  policy_item_weekly {
    frequency_interval = 4        # accepted values = 1 to 7 -> every 1=Monday,2=Tuesday,3=Wednesday,4=Thursday,5=Friday,6=Saturday,7=Sunday day of the week
    retention_unit     = "weeks"
    retention_value    = 3
  }
  policy_item_monthly {
    frequency_interval = 5        # accepted values = 1 to 28 -> 1 to 28 every nth day of the month  
                                  # accepted values = 40 -> every last day of the month
    retention_unit     = "months"
    retention_value    = 4
  }
  policy_item_yearly {
    frequency_interval = 1        # accepted values = 1 to 12 -> 1st day of nth month  
    retention_unit     = "years"
    retention_value    = 1
  }
}
