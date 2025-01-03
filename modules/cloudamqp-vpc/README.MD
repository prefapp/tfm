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
| <a name="resource_cloudamqp_vpc"></a> [cloudamqp_vpc](#resource\_cloudamqp\_vpc) | [cloudamqp_vpc](https://registry.terraform.io/providers/cloudamqp/cloudamqp/1.32.2/docs/resources/vpc) |
| <a name="resource_cloudamqp_vpc_connect"></a> [cloudamqp_vpc_connect](#resource\_cloudamqp\_vpc\_connect) | [cloudamqp_vpc_connect](https://registry.terraform.io/providers/cloudamqp/cloudamqp/1.32.2/docs/resources/vpc_connect) |


## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloudamqp_vpc"></a> [cloudamqp_vpc](#input\_cloudamqp\_vpc) | Map of CloudAMQP VPC configurations. | <pre>object({<br>  name   = string<br>  region = string<br>  subnet = string<br>  tags   = optional(list(string))<br>})</pre> | n/a | yes |
| <a name="input_cloudamqp_vpc_connect"></a> [cloudamqp_vpc_connect](#input\_cloudamqp\_vpc\_connect) | Map of CloudAMQP VPC Connect configurations. | <pre>object({<br>  instance_id            = number<br>  region                 = string<br>  approved_subscriptions = optional(list(string))<br>  sleep                  = optional(number)<br>  timeout                = optional(number)<br>})</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_vpc_id"></a> [vpc_id](#output\_vpc\_id) | ID of the created VPC. |
| <a name="output_vpc_name"></a> [vpc_name](#output\_vpc\_name) | Name of the created VPC. |
| <a name="output_id"></a> [id](#output\_id) | The identifier for this resource. Will be the same as `instance_id`. |
| <a name="output_status"></a> [status](#output\_status) | Private Service Connect status [enable, pending, disable]. |
