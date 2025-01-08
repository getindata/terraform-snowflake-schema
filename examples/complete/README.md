# Complete Example

This is complete usage example of `snowflake-schema` terraform module.

## Usage
Populate `.env` file with Snowflake credentials and make sure it's sourced to your shell.

## How to plan

```shell
terraform init
terraform plan -var-file=fixtures.tfvars
```

## How to apply

```shell
terraform init
terraform apply -var-file=fixtures.tfvars
```

## How to destroy

```shell
terraform destroy -var-file=fixtures.tfvars
```


<!-- BEGIN_TF_DOCS -->




## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_context_templates"></a> [context\_templates](#input\_context\_templates) | A map of context templates used to generate names | `map(string)` | n/a | yes |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_existing_schema"></a> [existing\_schema](#module\_existing\_schema) | ../../ | n/a |
| <a name="module_marts_schema"></a> [marts\_schema](#module\_marts\_schema) | ../../ | n/a |
| <a name="module_raw_schema"></a> [raw\_schema](#module\_raw\_schema) | ../../ | n/a |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_marts_schema"></a> [marts\_schema](#output\_marts\_schema) | Schema module outputs |
| <a name="output_raw_schema"></a> [raw\_schema](#output\_raw\_schema) | Schema module outputs |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_snowflake"></a> [snowflake](#provider\_snowflake) | >= 0.95 |

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_context"></a> [context](#requirement\_context) | >=0.4.0 |
| <a name="requirement_snowflake"></a> [snowflake](#requirement\_snowflake) | >= 0.95 |

## Resources

| Name | Type |
|------|------|
| [snowflake_account_role.role_1](https://registry.terraform.io/providers/Snowflake-Labs/snowflake/latest/docs/resources/account_role) | resource |
| [snowflake_database.this](https://registry.terraform.io/providers/Snowflake-Labs/snowflake/latest/docs/resources/database) | resource |
| [snowflake_database_role.db_role_1](https://registry.terraform.io/providers/Snowflake-Labs/snowflake/latest/docs/resources/database_role) | resource |
| [snowflake_database_role.db_role_2](https://registry.terraform.io/providers/Snowflake-Labs/snowflake/latest/docs/resources/database_role) | resource |
| [snowflake_database_role.db_role_3](https://registry.terraform.io/providers/Snowflake-Labs/snowflake/latest/docs/resources/database_role) | resource |
| [snowflake_schema.this](https://registry.terraform.io/providers/Snowflake-Labs/snowflake/latest/docs/resources/schema) | resource |
| [snowflake_table.table_1](https://registry.terraform.io/providers/Snowflake-Labs/snowflake/latest/docs/resources/table) | resource |
| [snowflake_table.table_2](https://registry.terraform.io/providers/Snowflake-Labs/snowflake/latest/docs/resources/table) | resource |
<!-- END_TF_DOCS -->
