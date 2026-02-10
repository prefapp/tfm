# **AWS OIDC Terraform Module**

## Overview

This module enables **OIDC-based authentication between GitHub and an AWS account**, allowing GitHub Actions workflows to **push Docker images to Amazon ECR repositories** without using long-lived AWS credentials.

Access is controlled through the `subs` variable, which defines which GitHub repositories, branches, or tags are allowed to assume the IAM role.

---

## Key Features

- **AWS IAM OIDC Provider**  
  Creates an IAM OIDC provider using GitHub’s OIDC endpoint and thumbprint.

- **IAM Policy for ECR**  
  Creates an IAM policy with the required permissions to push images to Amazon ECR.

- **IAM Role**  
  Creates an IAM role that can be assumed via OIDC and is attached to the ECR policy.

---

## Basic Usage

### Minimal Example

```hcl
module "oidc" {
  source = "git::https://github.com/prefapp/tfm.git//modules/aws-oidc"
  organization = "1111111111111"
  subs = [
    "repo:ORG/repo-a:*",
    "repo:ORG/repo-b:*",
    "repo:ORG-B/repo-a:ref:refs/heads/dev",
    "repo:ORG-B/repo-z:ref:refs/tags/*"
  ]
}
```

---

### Allow uploads only from specific tags

```hcl
module "oidc" {
  source = "git::https://github.com/prefapp/tfm.git//modules/aws-oidc"
  organization = "1111111111111"
  subs = [
    "repo:ORG-B/repo-z:ref:refs/tags/*"
  ]
}
```

---

### Allow uploads only from a specific branch

```hcl
module "oidc" {
  source = "git::https://github.com/prefapp/tfm.git//modules/aws-oidc"
  organization = "1111111111111"
  subs = [
    "repo:ORG-B/repo-a:ref:refs/heads/dev"
  ]
}
```

---

## File Structure

The module is organized as follows:

```
├── main.tf
├── outputs.tf
├── README.md
└── variables.tf
```
