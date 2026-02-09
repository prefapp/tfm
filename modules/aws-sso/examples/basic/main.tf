# Basic example for AWS SSO module
# Requires a sso.yaml file in the same directory or specified path

module "aws_sso_basic" {
  source = "git::https://github.com/prefapp/tfm.git//modules/aws-sso" # Path to the module

  data_file           = "${path.module}/sso.yaml"
  identity_store_arn  = "arn:aws:sso:::instance/ssoins-1234567890abcdef"  # Replace with your instance ARN
  store_id            = "d-1234567890"  # Replace with your Identity Store ID
}

# Example sso.yaml content (create this file separately)
# users:
#   - name: "userA"
#     email: "test@test.test"
#     fullname: "userA"
# groups:
#   - name: "groupA"
#     users:
#       - userA
# permission-sets:
#   - name: "permission-set-basic"
#     managed-policies:
#       - "arn:aws:iam::aws:policy/ReadOnlyAccess"
# attachments:
#   "123456789012":
#     permission-set-basic:
#       groups:
#         - groupA
