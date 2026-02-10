# Advanced example for AWS SSO module with mixed policies
# Requires a sso.yaml file in the same directory or specified path

module "aws_sso_advanced" {
  source = "../.." # Relative path to the module

  data_file           = "${path.module}/sso.yaml"
  identity_store_arn  = "arn:aws:sso:::instance/ssoins-1234567890abcdef"  # Replace with your instance ARN
  store_id            = "d-1234567890"  # Replace with your Identity Store ID
}

# Create a sso.yaml file alongside this main.tf with your desired users, groups,
# permission sets, and attachments. This example expects sso.yaml to define:
#   - users
#   - groups
#   - permission-sets
#   - attachments
#
# See the module documentation or the example sso.yaml file in this directory
# for a complete example configuration.
