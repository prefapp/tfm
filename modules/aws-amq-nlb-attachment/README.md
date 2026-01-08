<!-- BEGIN_TF_DOCS -->
# aws-amq-nlb-attachment

## Overview

This module associates Amazon MQ broker ENIs (private IPs) to a Network Load Balancer (NLB) target group.

## Key Features
- Attach one or more Amazon MQ broker instances to an NLB target group
- Supports multi-AZ deployments (multiple IPs)
- Simple interface: just provide broker IPs and target group ARN

## Usage
```hcl
module "mq_nlb_attachment" {
	source             = "../aws-mq-nlb-attachment"
	broker_private_ips = ["10.0.1.100", "10.0.2.101"]
	target_group_arn   = "arn:aws:elasticloadbalancing:eu-west-1:123456789012:targetgroup/example-tg/abcdef1234567890"
}
```

## Requirements
- An existing Amazon MQ broker (RabbitMQ) with one or more instances
- An existing Network Load Balancer and target group
- The private IPs of the broker instances

## Inputs
See [variables.tf](../variables.tf) for a full list of input variables.

## Outputs
See [outputs.tf](../outputs.tf) for a full list of outputs.

## Examples
See the [examples directory](../\_examples/basic) for a working usage example.

## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_lb_target_group_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group_attachment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_broker_private_ips"></a> [broker\_private\_ips](#input\_broker\_private\_ips) | List of private IPs of the broker instances | `list(string)` | n/a | yes |
| <a name="input_target_group_arn"></a> [target\_group\_arn](#input\_target\_group\_arn) | ARN of the NLB target group | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_attachment_ids"></a> [attachment\_ids](#output\_attachment\_ids) | IDs of the target group attachments |

## Examples

For detailed examples, refer to the [module examples](https://github.com/prefapp/tfm/tree/main/modules/aws-mq-nlb-attachment/_examples):

- [Basic](https://github.com/prefapp/tfm/tree/main/modules/aws-cloudfront-delivery/_examples/basic) - Basic configuration

## Resources

- [Amazon MQ (RabbitMQ)](https://docs.aws.amazon.com/amazon-mq/latest/developer-guide/what-is-amazon-mq.html): Managed message broker service for RabbitMQ.
- [Network Load Balancer (NLB)](https://docs.aws.amazon.com/elasticloadbalancing/latest/network/introduction.html): High-performance load balancer for TCP/UDP traffic.
- [aws\_lb\_target\_group\_attachment (Terraform)](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group_attachment): Terraform resource for attaching targets to a load balancer target group.

## Support

For issues, questions, or contributions related to this module, please visit the [repository’s issue tracker](https://github.com/prefapp/tfm/issues)
<!-- END_TF_DOCS -->
