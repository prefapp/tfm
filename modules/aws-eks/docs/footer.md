## Examples

For detailed examples, refer to the [module examples](https://github.com/prefapp/tfm/tree/main/modules/aws-eks/_examples):

- [karpenter](https://github.com/prefapp/tfm/tree/main/modules/aws-eks/_examples/karpenter) - Configuration with karpenter module.
- [with_firestartr_role_discovery](https://github.com/prefapp/tfm/tree/main/modules/aws-eks/_examples/with_firestartr_role_discovery) - Enable Backstage and ArgoCD access by discovering IAM roles with the default Firestartr names and tags.
- [with_custom_role_discovery](https://github.com/prefapp/tfm/tree/main/modules/aws-eks/_examples/with_custom_role_discovery) - Enable Backstage and ArgoCD access by discovering existing IAM roles with custom names and tags, without Firestartr conventions.
- [with_import](https://github.com/prefapp/tfm/tree/main/modules/aws-eks/_examples/with_import) - Import existing eks.
- [with_vpc](https://github.com/prefapp/tfm/tree/main/modules/aws-eks/_examples/with_vpc) - Generate EKS in an existing VPC and configure optional custom Backstage and ArgoCD IAM-role discovery.

## Remote resources

- **EKS**: [https://aws.amazon.com/eks/](https://aws.amazon.com/eks/)
- **Terraform-aws-modules/eks/aws**: [https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest](https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest)
- **Terraform-aws-modules/eks/aws/latest/submodules/karpenter**: [https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest/submodules/karpenter](https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest/submodules/karpenter)
- **Terraform AWS Provider**: [https://registry.terraform.io/providers/hashicorp/aws/latest](https://registry.terraform.io/providers/hashicorp/aws/latest)

## Support

For issues, questions, or contributions related to this module, please visit the repository’s issue tracker: [https://github.com/prefapp/tfm/issues](https://github.com/prefapp/tfm/issues)
