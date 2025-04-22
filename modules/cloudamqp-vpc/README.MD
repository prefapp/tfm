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

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloudamqp_vpc"></a> [cloudamqp_vpc](#input\_cloudamqp\_vpc) | CloudAMQP VPC configurations. | <pre>object({<br>  name   = string<br>  region = string<br>  subnet = string<br>  tags   = optional(list(string))<br>})</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_vpc_id"></a> [vpc_id](#output\_vpc\_id) | ID of the created VPC. |
| <a name="output_vpc_name"></a> [vpc_name](#output\_vpc\_name) | Name of the created VPC. |

## Example 1: tfvars

```hcl
cloudamqp_vpc = {
  name   = "example-dev-vpc"
  region = "azure-arm::eastus"
  subnet = "
  tags   = ["example", "dev"]
}
```

## Example 2: yaml

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
    module: git::https://github.com/prefapp/tfm.git//modules/cloudamqp-vpc?ref=example-version
    values:
      cloudamqp_vpc:
        name: "example-dev-vpc"
        region: "azure-arm::eastus"
        subnet: "10.0.0.0/24"
        tags:
          - "example"
          - "dev"
    context:
      providers:
        - name: cloudamqp-example
        - name: azure-provider-example
      backend:
        name: azure-backend-example
```

