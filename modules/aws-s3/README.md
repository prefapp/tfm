<!-- BEGIN_TF_DOCS -->
# **AWS S3 Terraform Module**

## Overview

This module is designed to provision Amazon S3 buckets with advanced features such as cross-account (and cross-region) replication, default and custom lifecycle rules, and versioning. It also supports configuring buckets to allow replication from other sources and can be used with existing buckets to add replication and lifecycle management capabilities.

This module provisions the following resources:

- Amazon S3 bucket
- Replication configuration
- Lifecycle rules
- S3 permissions
- IAM role for replication

It is flexible, production-ready, and easy to integrate into existing infrastructures.

## Key Features

- **Amazon S3 bucket** provisioning
- **Replication** across accounts and regions
- **Lifecycle management** with default and custom rules
- **Versioning** support
- **IAM role** for replication
- **Support for existing buckets**

## Basic Usage

### Minimal Example (S3 bucket)

```hcl
module "s3" {
  source = "github.com/prefapp/tfm/modules/aws-s3"
  bucket = "my-bucket"
}
```

### Enabling Replication to Another Bucket

```hcl
module "s3" {
  source               = "github.com/prefapp/tfm/modules/aws-s3"
  bucket               = "my-bucket-origin"
  region               = "eu-west-1"
  s3_bucket_versioning = "Enabled"
  s3_replication_destination = {
    account       = "1122334455"
    bucket_arn    = "arn:aws:s3:::my-bucket-destination"
    storage_class = "STANDARD"
  }
}
```

## Enabling accept copy from other bucket

```hcl
module "s3" {
  source = "github.com/prefapp/tfm/modules/aws-s3"

  bucket               = "my-bucket-origin"
  region               = "eu-west-1"
  s3_bucket_versioning = "Enabled"
  s3_replication_source = {
    account  = "5544332211"
    role_arn = "arn:aws:iam::5544332211:role/my-bucket-origin-replication"
  }
}
```

## File Structure

The module is organized with the following directory and file structure:

.
├── .terraform-docs.yml          # terraform-docs configuration
├── README.md                    # Auto-generated documentation
├── \_examples/
│   ├── basic/main.tf
│   ├── minimal\_destination\_source\_and\_destination/main.tf
│   ├── minimal\_replication/main.tf
│   └── minimal\_source/main.tf
├── data.tf                      # Data source for existing bucket
├── docs/
│   ├── footer.md
│   └── header.md
├── lifecycle.tf                 # Lifecycle configuration
├── local.tf                     # Locals (lifecycle rules merge)
├── main.tf                      # Bucket, ACL, policy, versioning
├── outputs.tf                   # Module outputs
├── replication.tf               # Replication + IAM
├── variables.tf                 # Input variables
└── versions.tf                  # Required providers
- **`data.tf`**: If bucket is not created, we use data of bucket
- **`lifecycle.tf`**: Lifecycle configurations for S3 buckets.
- **`main.tf`**: Entry point that wires together all module components.
- **`outputs.tf`**: Outputs of module
- **`replication.tf`**: Replication configuration of bucket

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 6.2 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.replication](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.replication](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.replication](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_s3_bucket.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_lifecycle_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_replication_configuration.origin_to_destination](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_replication_configuration) | resource |
| [aws_s3_bucket_versioning.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_iam_policy_document.assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.destination_replication_s3_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.only_https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.replication](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.source_replication_s3_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.source_replication_s3_policy_with_https_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_s3_bucket.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/s3_bucket) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_block_public_acls"></a> [block\_public\_acls](#input\_block\_public\_acls) | Whether to block public ACLs for the bucket. | `bool` | `null` | no |
| <a name="input_block_public_policy"></a> [block\_public\_policy](#input\_block\_public\_policy) | Whether to block public bucket policies for the bucket. | `bool` | `null` | no |
| <a name="input_bucket"></a> [bucket](#input\_bucket) | The name of the S3 bucket. | `string` | n/a | yes |
| <a name="input_bucket_public_access"></a> [bucket\_public\_access](#input\_bucket\_public\_access) | If true, block all public access to the bucket. | `bool` | `true` | no |
| <a name="input_create_bucket"></a> [create\_bucket](#input\_create\_bucket) | Whether to create a new bucket or use an existing one with the name specified in the 'bucket' variable. | `bool` | `true` | no |
| <a name="input_default_lifecycle_rules"></a> [default\_lifecycle\_rules](#input\_default\_lifecycle\_rules) | A list of lifecycle rules when replication or versioning is enabled to apply to the bucket. | <pre>list(object({<br/>    id     = string<br/>    status = optional(string)<br/>    filter = optional(object({<br/>      prefix = optional(string)<br/>      and = optional(object({<br/>        prefix                   = optional(string)<br/>        object_size_greater_than = optional(number)<br/>        object_size_less_than    = optional(number)<br/>      }))<br/>    }))<br/>    enabled = optional(bool)<br/>    prefix  = optional(string)<br/>    tags    = optional(map(string))<br/>    transitions = optional(list(object({<br/>      days          = number<br/>      storage_class = string<br/>    })))<br/>    expiration = optional(object({<br/>      days                         = optional(number)<br/>      expired_object_delete_marker = optional(bool)<br/>    }))<br/>    noncurrent_version_expiration = optional(object({<br/>      newer_noncurrent_versions = optional(number)<br/>      noncurrent_days           = optional(number)<br/>    }))<br/>    abort_incomplete_multipart_upload = optional(object({<br/>      days_after_initiation = number<br/>    }))<br/>  }))</pre> | <pre>[<br/>  {<br/>    "id": "Permanently delete noncurrent versions of objects after 3 days",<br/>    "noncurrent_version_expiration": {<br/>      "noncurrent_days": 3<br/>    },<br/>    "status": "Enabled"<br/>  },<br/>  {<br/>    "abort_incomplete_multipart_upload": {<br/>      "days_after_initiation": 2<br/>    },<br/>    "expiration": {<br/>      "expired_object_delete_marker": true<br/>    },<br/>    "id": "Delete expired objects and incomplete multipart uploads (after 2 days)",<br/>    "status": "Enabled"<br/>  }<br/>]</pre> | no |
| <a name="input_extra_bucket_iam_policies_json"></a> [extra\_bucket\_iam\_policies\_json](#input\_extra\_bucket\_iam\_policies\_json) | An array from JSON string representing additional IAM policies to attach to the bucket. | `list(string)` | `[]` | no |
| <a name="input_ignore_public_acls"></a> [ignore\_public\_acls](#input\_ignore\_public\_acls) | Whether to ignore public ACLs for the bucket. | `bool` | `null` | no |
| <a name="input_lifecycle_rules"></a> [lifecycle\_rules](#input\_lifecycle\_rules) | A list of lifecycle rules to apply to the bucket. | <pre>list(object({<br/>    id     = string<br/>    status = optional(string)<br/>    filter = optional(object({<br/>      prefix = optional(string)<br/>      and = optional(object({<br/>        prefix                   = optional(string)<br/>        object_size_greater_than = optional(number)<br/>        object_size_less_than    = optional(number)<br/>      }))<br/>    }))<br/>    enabled = optional(bool)<br/>    prefix  = optional(string)<br/>    tags    = optional(map(string))<br/>    transitions = optional(list(object({<br/>      days          = number<br/>      storage_class = string<br/>    })))<br/>    expiration = optional(object({<br/>      days                         = optional(number)<br/>      expired_object_delete_marker = optional(bool)<br/>    }))<br/>    noncurrent_version_expiration = optional(object({<br/>      newer_noncurrent_versions = optional(number)<br/>      noncurrent_days           = optional(number)<br/>    }))<br/>    abort_incomplete_multipart_upload = optional(object({<br/>      days_after_initiation = number<br/>    }))<br/><br/>  }))</pre> | `[]` | no |
| <a name="input_object_lock_enabled"></a> [object\_lock\_enabled](#input\_object\_lock\_enabled) | A boolean that indicates whether object lock is enabled for the bucket. | `bool` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | The AWS region where the S3 bucket will be created. | `string` | `null` | no |
| <a name="input_restrict_public_buckets"></a> [restrict\_public\_buckets](#input\_restrict\_public\_buckets) | Whether to restrict public bucket policies for the bucket. | `bool` | `null` | no |
| <a name="input_s3_bucket_versioning"></a> [s3\_bucket\_versioning](#input\_s3\_bucket\_versioning) | The versioning state of the S3 bucket. Valid values are 'Enabled' and 'Suspended'. | `string` | `"Suspended"` | no |
| <a name="input_s3_replication_destination"></a> [s3\_replication\_destination](#input\_s3\_replication\_destination) | Object containing the replication destination configuration. | <pre>object({<br/>    account       = string<br/>    bucket_arn    = string<br/>    storage_class = string<br/>    filter = optional(object({<br/>      prefix = optional(string)<br/>      tags   = optional(map(string))<br/>      and = optional(object({<br/>        prefix = optional(string)<br/>        tags   = optional(map(string))<br/>      }))<br/>    }))<br/>  })</pre> | `null` | no |
| <a name="input_s3_replication_role_suffix"></a> [s3\_replication\_role\_suffix](#input\_s3\_replication\_role\_suffix) | Suffix to add to the replication role name. This is useful to avoid name conflicts when creating multiple replication roles in the same account. | `string` | `"-replication"` | no |
| <a name="input_s3_replication_source"></a> [s3\_replication\_source](#input\_s3\_replication\_source) | Object containing the replication source configuration. | <pre>object({<br/>    account  = string<br/>    role_arn = string<br/>    filter = optional(object({<br/>      prefix = optional(string)<br/>      tags   = optional(map(string))<br/>      and = optional(object({<br/>        prefix = optional(string)<br/>        tags   = optional(map(string))<br/>      }))<br/>    }))<br/>  })</pre> | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to the resource. | `map(string)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bucket_arn"></a> [bucket\_arn](#output\_bucket\_arn) | ARN of the bucket that is created or whose data is obtained |
| <a name="output_bucket_domain_name"></a> [bucket\_domain\_name](#output\_bucket\_domain\_name) | Domain name of the bucket that is created or whose data is obtained |
| <a name="output_bucket_id"></a> [bucket\_id](#output\_bucket\_id) | Name of the bucket that is created or whose data is obtained |
| <a name="output_replication_destination_bucket_arn"></a> [replication\_destination\_bucket\_arn](#output\_replication\_destination\_bucket\_arn) | ARN of the replication destination bucket |
| <a name="output_replication_role_arn"></a> [replication\_role\_arn](#output\_replication\_role\_arn) | ARN of the replication role |
| <a name="output_replication_s3_destination_replication_s3_policy_json"></a> [replication\_s3\_destination\_replication\_s3\_policy\_json](#output\_replication\_s3\_destination\_replication\_s3\_policy\_json) | JSON policy for S3 replication in the destination bucket, to be applied to that bucket. |

## Examples

For detailed examples, refer to the [module examples](https://github.com/prefapp/tfm/tree/main/modules/aws-s3/_examples):

- [Basic](https://github.com/prefapp/tfm/tree/main/modules/aws-s3/_examples/basic) – Basic S3 bucket with HTTPS-only access rules.
- [Minimal Replication](https://github.com/prefapp/tfm/tree/main/modules/aws-s3/_examples/minimal\_replication) – Minimal S3 bucket configured to replicate objects to another bucket.
- [Minimal Source](https://github.com/prefapp/tfm/tree/main/modules/aws-s3/_examples/minimal\_source) – Minimal S3 bucket configured as a replication source.
- [Minimal Destination Source and Destination](https://github.com/prefapp/tfm/tree/main/modules/aws-s3/_examples/minimal\_destination\_source\_and\_destination) – S3 bucket configured as both replication source and destination.

## Remote Resources

- [Terraform](https://www.terraform.io/)
- [Amazon S3](https://aws.amazon.com/s3/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest)

## Support

For issues, questions, or contributions related to this module, please visit the repository’s issue tracker: [https://github.com/prefapp/tfm/issues](https://github.com/prefapp/tfm/issues)
<!-- END_TF_DOCS -->