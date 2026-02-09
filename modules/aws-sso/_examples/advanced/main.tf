# Advanced example for AWS SSO module with mixed policies
# Requires a sso.yaml file in the same directory or specified path

module "aws_sso_advanced" {
  source = "../.." # Relative path to the module

  data_file           = "${path.module}/sso.yaml"
  identity_store_arn  = "arn:aws:sso:::instance/ssoins-1234567890abcdef"  # Replace with your instance ARN
  store_id            = "d-1234567890"  # Replace with your Identity Store ID
}

# Example sso.yaml content (create this file separately)
# users:
#   - name: "userA"
#     email: "test@test.test"
#     fullname: "userA"
#   - name: "userB"
#     email: "test2@test.test"
#     fullname: "userB"
# groups:
#   - name: "groupA"
#     users:
#       - userA
#       - userB
# permission-sets:
#   - name: "permission-set-advanced"
#     custom-policies:
#       - name: "custom-policy-example"
#     managed-policies:
#       - "arn:aws:iam::aws:policy/AmazonS3FullAccess"
#     inline-policies:
#       - name: "inline-policy-example"
#         policy: |
#           {
#             "Version": "2012-10-17",
#             "Statement": [
#               {
#                 "Effect": "Allow",
#                 "Action": ["ec2:Describe*"],
#                 "Resource": "*"
#               }
#             ]
#           }
# attachments:
#   "123456789012":
#     permission-set-advanced:
#       groups:
#         - groupA
#       users:
#         - userA
#   "210987654321":
#     permission-set-advanced:
#       groups:
#         - groupA
