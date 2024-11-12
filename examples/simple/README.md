# Simple example

This is simple usage example of `snowflake-schema` terraform module.

## Usage
Populate `.env` file with Snowflake credentials and make sure it's sourced to your shell.

## How to plan

```shell
terraform init
terraform plan
```

## How to apply

```shell
terraform init
terraform apply
```

## How to destroy

```shell
terraform destroy
```

<!-- BEGIN_TF_DOCS -->




## Inputs

No inputs.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_this_schema"></a> [this\_schema](#module\_this\_schema) | ../../ | n/a |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_schema"></a> [schema](#output\_schema) | Schema module outputs |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_snowflake"></a> [snowflake](#provider\_snowflake) | ~> 0.94 |

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_snowflake"></a> [snowflake](#requirement\_snowflake) | ~> 0.94 |

## Resources

| Name | Type |
|------|------|
| [snowflake_database.test](https://registry.terraform.io/providers/Snowflake-Labs/snowflake/latest/docs/resources/database) | resource |
<!-- END_TF_DOCS -->
