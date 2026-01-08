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
See the [examples directory](../_examples/basic) for a working usage example.
