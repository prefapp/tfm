locals {

  # let's read the info first
  yaml = yamldecode(file(var.data_file))

  users_by_name = {

    for user in local.yaml.users : user.name => user   

  }

  groups_by_name = {

    for group in local.yaml.groups : group.name => group

  }

  users_in_groups = flatten([

    for group in local.yaml.groups : [

      for user in group.users: "${user},${group.name}"

    ]

  ])

}

# We need to create the users 
resource "aws_identitystore_user" "users" {
  
  for_each = { local.users_by_name }

  identity_store_id = var.identity_store_arn

  user_name = each.value.email
 
  name = each.value.fullname ? each.value.fullname : each.key

  emails {

     value = each.value.email

  }  

}

resource "aws_identitystore_group" "groups" {

  for_each = { local.groups_by_name }
  
  display_name = each.name

  identity_store_id = var.identity_store_arn

  depends_on = [

    aws_identitystore_user.users

  ]
}

resource "aws_identitystore_group_membership" "groups-users" {
  
  identity_store_id = var.identity_store_arn

  for_each = { local.users_in_groups }

  group_id          = aws_identitystore_group.groups[split(",", each.key)[1]].group_id

  member_id         = aws_identitystore_user.users[split(",", each.key)[0]].user_id

}

