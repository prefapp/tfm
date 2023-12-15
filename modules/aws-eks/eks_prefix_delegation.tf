/*
  This Terraform script is used to enable prefix delegation in the AWS VPC CNI 
  for an EKS cluster. It defines a local variable for the VPC CNI addon version 
  and creates a null resource that triggers on the change of the VPC CNI addon 
  version. When triggered, it executes a command to enable prefix delegation. 
  This is particularly useful for scenarios where a large number of IP addresses 
  are required.
*/

// Define local variable for the VPC CNI addon version
locals {
  vpc_cni_addon = module.eks.cluster_addons.vpc-cni.addon_version
}

// Create a null resource to enable prefix delegation
resource "null_resource" "prefix_delegation" {
  triggers = {
    cluster_endpoint = local.vpc_cni_addon
    cmd_patch        = "kubectl set env daemonset aws-node -n kube-system ENABLE_PREFIX_DELEGATION=true"
  }

// Execute the command to enable prefix delegation
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = self.triggers.cmd_patch
  }

}
