locals {
  auto_scaler_profile = var.auto_scaler_profile == null ? null : {
    balance_similar_node_groups           = var.auto_scaler_profile.balance_similar_node_groups
    daemonset_eviction_for_empty_nodes    = var.auto_scaler_profile.daemonset_eviction_for_empty_nodes
    daemonset_eviction_for_occupied_nodes = var.auto_scaler_profile.daemonset_eviction_for_occupied_nodes
    expander                              = var.auto_scaler_profile.expander
    ignore_daemonsets_utilization         = var.auto_scaler_profile.ignore_daemonsets_utilization
    max_empty_bulk_delete                 = var.auto_scaler_profile.max_empty_bulk_delete
    max_graceful_termination_sec          = var.auto_scaler_profile.max_graceful_termination_sec
    max_node_provision_time               = var.auto_scaler_profile.max_node_provision_time
    max_total_unready_percentage          = var.auto_scaler_profile.max_total_unready_percentage
    new_pod_scale_up_delay                = var.auto_scaler_profile.new_pod_scale_up_delay
    ok_total_unready_count                = var.auto_scaler_profile.ok_total_unready_count
    scale_down_delay_after_add            = var.auto_scaler_profile.scale_down_delay_after_add
    scale_down_delay_after_delete         = var.auto_scaler_profile.scale_down_delay_after_delete
    scale_down_delay_after_failure        = var.auto_scaler_profile.scale_down_delay_after_failure
    scale_down_unneeded_time              = var.auto_scaler_profile.scale_down_unneeded_time
    scale_down_unready_time               = var.auto_scaler_profile.scale_down_unready_time
    scale_down_utilization_threshold      = var.auto_scaler_profile.scale_down_utilization_threshold
    scan_interval                         = var.auto_scaler_profile.scan_interval
    skip_nodes_with_local_storage         = var.auto_scaler_profile.skip_nodes_with_local_storage
    skip_nodes_with_system_pods           = var.auto_scaler_profile.skip_nodes_with_system_pods
  }
}
