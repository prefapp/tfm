locals {
  vpc_cni_addon = module.eks.cluster_addons.vpc-cni.addon_version
}

resource "null_resource" "prefix_delegation" {
  triggers = {
    cluster_endpoint = local.vpc_cni_addon
    cmd_patch        = "kubectl set env daemonset aws-node -n kube-system ENABLE_PREFIX_DELEGATION=true"
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = self.triggers.cmd_patch
  }

}
