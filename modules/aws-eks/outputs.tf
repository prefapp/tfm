output "account_id" {

  value = data.aws_caller_identity.current.account_id

}

output "eks_module_version" {

  value = local.eks_module_version

}
