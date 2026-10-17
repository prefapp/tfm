

provider "kubernetes" {
  host                   = data.ovh_cloud_project_kube.my_kube_cluster.kubeconfig_attributes[0].host
  client_certificate     = base64decode(data.ovh_cloud_project_kube.my_kube_cluster.kubeconfig_attributes[0].client_certificate)
  client_key             = base64decode(data.ovh_cloud_project_kube.my_kube_cluster.kubeconfig_attributes[0].client_key)
  cluster_ca_certificate = base64decode(data.ovh_cloud_project_kube.my_kube_cluster.kubeconfig_attributes[0].cluster_ca_certificate)
}
