locals {
  auto_scaler_profile = var.auto_scaler_profile == null ? null : {
    balance-similar-node-groups           = var.auto_scaler_profile.balance_similar_node_groups
    daemonset-eviction-for-empty-nodes    = var.auto_scaler_profile.daemonset_eviction_for_empty_nodes
    daemonset-eviction-for-occupied-nodes = var.auto_scaler_profile.daemonset_eviction_for_occupied_nodes
    expander                              = var.auto_scaler_profile.expander
    ignore-daemonsets-utilization         = var.auto_scaler_profile.ignore_daemonsets_utilization
    max-empty-bulk-delete                 = var.auto_scaler_profile.max_empty_bulk_delete
    max-graceful-termination-sec          = var.auto_scaler_profile.max_graceful_termination_sec
    max-node-provision-time               = var.auto_scaler_profile.max_node_provision_time
    max-total-unready-percentage          = var.auto_scaler_profile.max_total_unready_percentage
    new-pod-scale-up-delay                = var.auto_scaler_profile.new_pod_scale_up_delay
    ok-total-unready-count                = var.auto_scaler_profile.ok_total_unready_count
    scale-down-delay-after-add            = var.auto_scaler_profile.scale_down_delay_after_add
    scale-down-delay-after-delete         = var.auto_scaler_profile.scale_down_delay_after_delete
    scale-down-delay-after-failure        = var.auto_scaler_profile.scale_down_delay_after_failure
    scale-down-unneeded-time              = var.auto_scaler_profile.scale_down_unneeded_time
    scale-down-unready-time               = var.auto_scaler_profile.scale_down_unready_time
    scale-down-utilization-threshold      = var.auto_scaler_profile.scale_down_utilization_threshold
    scan-interval                         = var.auto_scaler_profile.scan_interval
    skip-nodes-with-local-storage         = var.auto_scaler_profile.skip_nodes_with_local_storage
    skip-nodes-with-system-pods           = var.auto_scaler_profile.skip_nodes_with_system_pods
  }
}
