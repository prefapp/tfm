# https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/resources/cloud_backup_schedule
resource "mongodbatlas_cloud_backup_schedule" "this" {
  project_id   = var.project_id
  cluster_name = mongodbatlas_cluster.this.name

  reference_hour_of_day    = var.snapshot_execution_config.reference_hour_of_day
  reference_minute_of_hour = var.snapshot_execution_config.reference_minute_of_hour
  restore_window_days      = var.snapshot_execution_config.restore_window_days

  dynamic "policy_item_hourly" {
    for_each = var.scheduled_retention_policies.hourly != null ? [var.scheduled_retention_policies.hourly] : []
    content {
      frequency_interval = hourly.value.frequency_interval
      retention_unit     = hourly.value.retention_unit
      retention_value    = hourly.value.retention_value
    }
  }

  dynamic "policy_item_daily" {
    for_each = var.scheduled_retention_policies.daily != null ? [var.scheduled_retention_policies.daily] : []
    content {
      frequency_interval = daily.value.frequency_interval
      retention_unit     = daily.value.retention_unit
      retention_value    = daily.value.retention_value
    }
  }

  dynamic "policy_item_monthly" {
    for_each = var.scheduled_retention_policies.weekly != null ? [var.scheduled_retention_policies.weekly] : []
    content {
      frequency_interval = policy_item_monthly.value.frequency_interval
      retention_unit     = policy_item_monthly.value.retention_unit
      retention_value    = policy_item_monthly.value.retention_value
    }
  }  

  dynamic "policy_item_monthly" {
    for_each = var.scheduled_retention_policies.monthly != null ? [var.scheduled_retention_policies.monthly] : []
    content {
      frequency_interval = policy_item_monthly.value.frequency_interval
      retention_unit     = policy_item_monthly.value.retention_unit
      retention_value    = policy_item_monthly.value.retention_value
    }
  }

  dynamic "policy_item_yearly" {
    for_each = var.scheduled_retention_policies.yearly != null ? [var.scheduled_retention_policies.yearly] : []
    content {
      frequency_interval = policy_item_yearly.value.frequency_interval
      retention_unit     = policy_item_yearly.value.retention_unit
      retention_value    = policy_item_yearly.value.retention_value
    }
  }
}
