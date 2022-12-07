locals {

  permissions_by_name = {
  
    for permission in local.yaml.permission-sets: permission.name => permission
  
  }
  
  permissions_custom_policies = flatten([
  
    for permission in local.yaml.permission-sets: [
  
      for custom-policy in permission.custom-policies: "${permission.name},${custom-policy.name},${lookup(custom-policy, "path", "/")}"
  
    ]
  
  ])

  permissions_managed_policies = flatten([
  
    for permission in local.yaml.permission-sets: [
  
      for managed-policy in permission.managed-policies: "${permission.name},${managed-policy}"
  
    ]
  
  ])

  permissions_inline_policies= flatten([
  
    for permission in local.yaml.permission-sets: [
  
      for inline-policy in permission.inline-policies: "${permission.name},${base64encode(inline-policy.policy)}"
  
    ]
  
  ])

}

resource "aws_ssoadmin_permission_set" "permissions" {

  for_each = local.permissions_by_name
  
  instance_arn = var.identity_store_arn
  
  name = each.key
  
  description = lookup(each.value, "description", null)
  
  session_duration = lookup(each.value, "session_duration", null)
}

resource "aws_ssoadmin_customer_managed_policy_attachment" "permissions-custom-policies" {

  for_each = toset(local.permissions_custom_policies)
  
  instance_arn = var.identity_store_arn
 
  permission_set_arn = aws_ssoadmin_permission_set.permissions[split(",", each.value)[0]].arn

  customer_managed_policy_reference {

    name = split(",", each.value)[1]

    path = split(",", each.value)[2]

  }
}

resource "aws_ssoadmin_managed_policy_attachment" "permissions-managed-policies" {

  for_each = toset(local.permissions_managed_policies)
  
  instance_arn = var.identity_store_arn
 
  permission_set_arn = aws_ssoadmin_permission_set.permissions[split(",", each.value)[0]].arn

  managed_policy_arn = split(",", each.value)[1]

}

resource "aws_ssoadmin_managed_policy_attachment" "permissions-inline-policies" {

  for_each = toset(local.permissions_managed_policies)
  
  permission_set_arn = aws_ssoadmin_permission_set.permissions[split(",", each.value)[0]].arn

  inline_policy = base64decode(split(",", each.value)[1])

}


