## Requirements

 Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.7.0 |
| <a name="requirement_cloudamqp"></a> [cloudamqp](#requirement\_cloudamqp) | >= 1.32.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_cloudamqp"></a> [cloudamqp](#provider\_cloudamqp) | >= 1.32.2 |

## Resources

| Name | Type |
|------|------|
| <a name="resource_cloudamqp_vpc"></a> [cloudamqp_vpc.this](https://registry.terraform.io/providers/cloudamqp/cloudamqp/latest/docs/resources/vpc) | resource |
| <a name="resource_cloudamqp_vpc_connect"></a> [cloudamqp_vpc_connect.this](https://registry.terraform.io/providers/cloudamqp/cloudamqp/latest/docs/resources/vpc_connect) | resource |


## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloudamqp_vpc"></a> [cloudamqp_vpc](#input\_cloudamqp\_vpc) | CloudAMQP VPC configurations. | <pre>object({<br>  name   = string<br>  region = string<br>  subnet = string<br>  tags   = optional(list(string))<br>})</pre> | n/a | yes |
| <a name="input_cloudamqp_vpc_connect"></a> [cloudamqp_vpc_connect](#input\_cloudamqp\_vpc\_connect) | CloudAMQP VPC Connect configurations. | <pre>object({<br>  instance_id            = number<br>  region                 = string<br>  approved_subscriptions = optional(list(string))<br>  sleep                  = optional(number)<br>  timeout                = optional(number)<br>})</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_vpc_id"></a> [vpc_id](#output\_vpc\_id) | ID of the created VPC. |
| <a name="output_vpc_name"></a> [vpc_name](#output\_vpc\_name) | Name of the created VPC. |
| <a name="output_id"></a> [id](#output\_id) | The identifier for this resource. Will be the same as `instance_id`. |
| <a name="output_status"></a> [status](#output\_status) | Private Service Connect status [enable, pending, disable]. |

## Example

```yaml
kind: TFWorkspaceClaim
lifecycle: production
name: example-cloudamqp-vpc
system: 'system:example'
version: '1.0'
providers:
  terraform:
    tfStateKey: 12345678-1234-1234-1234-123456789abc
    name: example-cloudamqp-vpc
    source: remote
    module: git::https://github.com/example/tfm.git//modules/cloudamqp-vpc?ref=example-branch
    values:
      cloudamqp_vpc:
        name: "example-dev-vpc"
        region: "azure-arm::eastus"
        subnet: "10.0.0.0/24"
        tags:
          - "example"
          - "dev"
      cloudamqp_vpc_connect:
        instance_id: 123456
        region: "azure-arm::eastus"
        approved_subcriptions:
          - "xxxxxx-xxxx-xxxx-xxxxxxx"
          - "xxxxxx-xxxx-xxxx-xxxxxxx"

    context:
      providers:
        - name: cloudamqp-example
        - name: azure-provider-example
      backend:
        name: azure-backend-example
```

