output "cluster_id" {
  description = "Managed Kubernetes cluster ID."
  value       = ovh_cloud_project_kube.production.id
}

output "cluster_name" {
  description = "Managed Kubernetes cluster name."
  value       = ovh_cloud_project_kube.production.name
}

output "cluster_status" {
  description = "Status reported by OVHcloud; expected to be READY after creation."
  value       = ovh_cloud_project_kube.production.status
}

output "kubeconfig" {
  description = "Kubeconfig for connecting to the cluster. Treat as a secret."
  value       = ovh_cloud_project_kube.production.kubeconfig
  sensitive   = true
}

output "nodepool_ids" {
  description = "Node pool IDs keyed by the corresponding node_pools map key."
  value       = { for name, pool in ovh_cloud_project_kube_nodepool.production : name => pool.id }
}
