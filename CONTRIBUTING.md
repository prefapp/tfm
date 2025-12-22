# Contributing to Prefapp TFM

Thank you for your interest in contributing to the Terraform Modules(TFM) repository! This guide will help you understand the standards and requirements for contributing new modules or updating existing ones.

## Module Documentation Standards

All Terraform modules in this repository must follow a standardized documentation structure to ensure consistency and ease of use. This section outlines the minimum requirements for module documentation as defined in [issue #786](https://github.com/prefapp/tfm/issues/786).

### Required Files and Structure

Each module must contain the following structure:

```
modules/<module-name>/
├── .terraform-docs.yml       # terraform-docs configuration
├── README.md                 # Auto-generated documentation
├── main.tf                   # Main module resources
├── variables.tf              # Input variables
├── outputs.tf                # Output values
├── docs/
│   ├── header.md             # Module overview and usage
│   └── footer.md             # Examples and resources
└── _examples/                # Usage examples
    └── <example-name>/       # At least one example
        └── main.tf
```

### 1. terraform-docs Configuration

Create a `.terraform-docs.yml` file in the module root with the following configuration:

```yaml
formatter: "markdown"

version: ""

header-from: docs/header.md
footer-from: docs/footer.md

recursive:
  enabled: false
  path: modules
  include-main: true

sections:
  hide: []
  show: []

content: ""

output:
  file: "README.md"
  mode: inject
  template: |-
    <!-- BEGIN_TF_DOCS -->
    {{ .Content }}
    <!-- END_TF_DOCS -->

output-values:
  enabled: false
  from: ""

sort:
  enabled: true
  by: name

settings:
  anchor: true
  color: true
  default: true
  description: false
  escape: true
  hide-empty: false
  html: true
  indent: 2
  lockfile: true
  read-comments: true
  required: true
  sensitive: true
  type: true
```

### 2. Header Documentation (`docs/header.md`)

The `header.md` file must contain at minimum the following sections:

````markdown
# **<Cloud Provider> <Resource Name> Terraform Module**

## Overview

<Provide a comprehensive description of what the module provisions and manages.
Include 2-3 paragraphs explaining:

- What resources are created
- Key capabilities and integrations
- Target use cases (dev, staging, production)>

## Key Features

- **<Feature 1>**: <Description of the feature>
- **<Feature 2>**: <Description of the feature>
- **<Feature 3>**: <Description of the feature>
- **<Feature N>**: <Description of the feature>

## Basic Usage

### <Usage Example 1 Description>

```hcl
module "example" {
  source = "git::https://github.com/prefapp/tfm.git//modules/<module-name>"

  # Configuration parameters
  parameter1 = "value1"
  parameter2 = "value2"
}
```

### <Usage Example 2 Description>

```hcl
module "example2" {
  source = "git::https://github.com/prefapp/tfm.git//modules/<module-name>"

  # Configuration parameters
  parameter1 = "value1"
  parameter2 = "value2"
}
```
````

**Guidelines for header.md**:

- Use bold `**` for module name in the title
- Overview should be 2-3 paragraphs minimum
- Include at least 3-5 key features with bold titles: `**Feature Name**: Description`
- Provide at least 2 basic usage examples showing different configurations
- Keep examples minimal and focused on core functionality
- Use proper HCL syntax highlighting with triple backticks

### 3. Footer Documentation (`docs/footer.md`)

The `footer.md` file must contain the following sections:

```markdown
## Examples

For detailed examples, refer to the [module examples](https://github.com/prefapp/tfm/tree/main/modules/<module-name>/_examples):

- [<Example 1>](https://github.com/prefapp/tfm/tree/main/modules/<module-name>/_examples/<example1>) - <Example 1 description>
- [<Example 2>](https://github.com/prefapp/tfm/tree/main/modules/<module-name>/_examples/<example2>) - <Example 2 description>

## Resources

- **<Resource 1 Name>**: [<URL to official documentation>]
- **<Resource 2 Name>**: [<URL to official documentation>]
- **Terraform AWS/Azure Provider**: [<URL to provider documentation>]

## Support

For issues, questions, or contributions related to this module, please visit the [repository's issue tracker](https://github.com/prefapp/tfm/issues).
```

**Guidelines for footer.md**:

- Link to all examples in the `_examples/` directory
- Provide brief, descriptive summaries for each example
- Include relevant resources (cloud provider docs, Terraform provider docs)
- Maintain consistent formatting and structure

### 4. Usage Examples (`_examples/`)

Each module must include at least one practical example in the `_examples/` directory:

```
_examples/
├── basic/                    # Minimal configuration example
│   └── main.tf
├── advanced/                 # Advanced features example
│   └── main.tf
└── <specific-use-case>/      # Use case specific example
    └── main.tf
```

**Guidelines for examples**:

- Each example should be in its own subdirectory
- Examples must be functional and demonstrate real-world usage
- Include comments explaining key configuration choices
- Ensure examples align with the Basic Usage section in header.md

### 5. README.md Generation

The `README.md` file is auto-generated by [terraform-docs](https://terraform-docs.io/) and should not be edited manually. To generate or update it:

```bash
cd modules/<module-name>
terraform-docs .
```

The `.terraform-docs.yml` configuration file already specifies all necessary parameters (formatter, output file, header/footer sources, etc.), so no additional arguments are needed.

The generated README will include:

- Content from `docs/header.md`
- Auto-generated documentation for inputs, outputs, resources, and providers
- Content from `docs/footer.md`

For more information about terraform-docs and its configuration options, visit the [official documentation](https://terraform-docs.io/).

### Reference Implementations

For examples of properly documented modules, refer to:

- [aws-rds](modules/aws-rds/) - Multi-engine database module
- [aws-ecs](modules/aws-ecs/) - ECS Fargate service module
- [aws-cloudfront-delivery](modules/aws-cloudfront-delivery/) - CloudFront distribution module

## Commit Message Guidelines

This repository uses [Conventional Commits](https://www.conventionalcommits.org/) for automated versioning and changelog generation through [Release Please](https://github.com/googleapis/release-please-action).

### Conventional Commit Format

All commit messages must follow the Conventional Commits specification. The most important prefixes are:

- **`fix:`** - Bug fixes (correlates to a PATCH version bump)
  ```
  fix: correct variable validation in aws-rds module
  ```

- **`feat:`** - New features (correlates to a MINOR version bump)
  ```
  feat: add support for Multi-AZ deployment in aws-rds
  ```

- **Breaking changes** - Use `!` after the type to indicate breaking changes (correlates to a MAJOR version bump)
  ```
  feat!: change default instance_class to db.t3.small
  fix!: remove deprecated parameter
  refactor!: restructure module outputs
  ```

### Other Useful Prefixes

- **`docs:`** - Documentation changes
- **`style:`** - Code style changes (formatting, no functional changes)
- **`refactor:`** - Code refactoring without changing functionality
- **`test:`** - Adding or updating tests
- **`chore:`** - Maintenance tasks (dependencies, build config, etc.)

### Commit Message Examples

```bash
# Adding a new feature
git commit -m "feat: add RDS-managed password rotation support"

# Fixing a bug
git commit -m "fix: resolve subnet group naming conflict"

# Breaking change
git commit -m "feat!: require vpc_tag_name instead of vpc_id

BREAKING CHANGE: vpc_id parameter has been removed in favor of vpc_tag_name"

# Documentation update
git commit -m "docs: update header.md with new usage examples"
```

### How Release Please Works

Release Please automatically:
1. Parses commit messages following Conventional Commits
2. Determines the next version number based on commit types
3. Creates and maintains Release PRs with updated changelogs
4. Generates GitHub releases when Release PRs are merged

When you're ready to release, simply merge the Release PR created by the bot.

For more information, see:
- [Conventional Commits](https://www.conventionalcommits.org/)
- [Release Please Documentation](https://github.com/googleapis/release-please-action)
- [SemVer](https://semver.org/)

## Pull Request Process

1. Ensure your module follows the documentation structure outlined above
2. Run `terraform-docs` to generate the README.md
3. Test your module with the provided examples
4. **Write commits using Conventional Commit format** (see above)
5. Submit a pull request with a clear description of changes
6. Reference any related issues (e.g., #786)

## Questions or Issues

If you have questions about the contribution process or documentation standards, please open an issue on the repository: [https://github.com/prefapp/tfm/issues](https://github.com/prefapp/tfm/issues)
