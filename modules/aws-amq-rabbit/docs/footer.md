## Examples

For detailed examples, refer to the [module examples](https://github.com/prefapp/tfm/tree/main/modules/aws-amq-rabbit/_examples):

- [Private Broker](https://github.com/prefapp/tfm/tree/main/modules/aws-amq-rabbit/_examples/private_broker) - Deploy a RabbitMQ broker in a private subnet
- [Private Broker with NLB](https://github.com/prefapp/tfm/tree/main/modules/aws-amq-rabbit/_examples/private_broker_with_nlb) - Deploy a private RabbitMQ broker with a Network Load Balancer
- [Public Broker](https://github.com/prefapp/tfm/tree/main/modules/aws-amq-rabbit/_examples/public_broker) - Deploy a RabbitMQ broker accessible from the public internet

## Remote resources
- Terraform: https://www.terraform.io/
- Terraform AWS Provider: https://registry.terraform.io/providers/hashicorp/aws/latest
- Amazon MQ (RabbitMQ): https://docs.aws.amazon.com/amazon-mq/latest/developer-guide/what-is-amazon-mq.html
- aws_mq_broker: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/mq_broker
- AWS VPC: https://docs.aws.amazon.com/vpc/latest/userguide/what-is-amazon-vpc.html
- aws_vpc: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc
- AWS Subnets: https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Subnets.html
- aws_subnets: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnets
- AWS Security Group: https://docs.aws.amazon.com/vpc/latest/userguide/VPC_SecurityGroups.html
- aws_security_group: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
- AWS Network Load Balancer: https://docs.aws.amazon.com/elasticloadbalancing/latest/network/introduction.html
- aws_lb: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb
- aws_lb_target_group: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group
- aws_lb_listener: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener

## Support

For issues, questions, or contributions related to this module, please visit the [repository’s issue tracker](https://github.com/prefapp/tfm/issues).
