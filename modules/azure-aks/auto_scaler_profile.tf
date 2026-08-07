locals {
  auto_scaler_profile = var.auto_scaler_profile_enabled ? {
    expander                         = var.auto_scaler_profile_expander
    max_graceful_termination_sec     = var.auto_scaler_profile_max_graceful_termination_sec
    max_node_provisioning_time       = var.auto_scaler_profile_max_node_provisioning_time
    max_unready_nodes                = var.auto_scaler_profile_max_unready_nodes
    max_unready_percentage           = var.auto_scaler_profile_max_unready_percentage
    new_pod_scale_up_delay           = var.auto_scaler_profile_new_pod_scale_up_delay
    scale_down_delay_after_add       = var.auto_scaler_profile_scale_down_delay_after_add
    scale_down_delay_after_delete    = var.auto_scaler_profile_scale_down_delay_after_delete
    scale_down_delay_after_failure   = var.auto_scaler_profile_scale_down_delay_after_failure
    scale_down_unneeded              = var.auto_scaler_profile_scale_down_unneeded
    scale_down_unready               = var.auto_scaler_profile_scale_down_unready
    scale_down_utilization_threshold = var.auto_scaler_profile_scale_down_utilization_threshold
    scan_interval                    = var.auto_scaler_profile_scan_interval
    skip_nodes_with_local_storage    = var.auto_scaler_profile_skip_nodes_with_local_storage
    skip_nodes_with_system_pods      = var.auto_scaler_profile_skip_nodes_with_system_pods
  } : null
}
