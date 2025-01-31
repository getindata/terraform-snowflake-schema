# Snowflake Schema Terraform Module
![Snowflake](https://img.shields.io/badge/-SNOWFLAKE-249edc?style=for-the-badge&logo=snowflake&logoColor=white)
![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white)

![License](https://badgen.net/github/license/getindata/terraform-snowflake-schema/)
![Release](https://badgen.net/github/release/getindata/terraform-snowflake-schema/)

<p align="center">
  <img height="150" src="https://getindata.com/img/logo.svg">
  <h3 align="center">We help companies turn their data into assets</h3>
</p>

---

Terraform module for Snowflake schema management.

- Creates Snowflake schema
- Can create custom Snowflake database roles with role-to-role assignments
- Can create a set of default database roles to simplify access management:
  - `READONLY` - granted select on all tables and views and usage on some objects in the schema
  - `READWRITE` - granted write type grants on tables and stages. Additionally, allows calling procedures and tasks in the schema
  - `TRANSFORMER` - Allows creating tables and views on top of the `READWRITE` role privileges
  - `ADMIN` - Full access, including setting schema options like `data_retention_days`
  - Each role can be disabled seperately by setting `enabled` to false - see [Complete example](examples/complete)
  - Each role can be additionally modified - see [Complete example](examples/complete)

## USAGE

```terraform
module "snowflake_schema" {
  source = "github.com/getindata/terraform-snowflake-schema"
  # version = "x.x.x"

  name     = "MY_SCHEMA"
  database = "MY_DB"

  is_managed          = false
  is_transient        = false
  data_retention_days = 1

  create_default_database_roles = true
}
```

## EXAMPLES

- [Complete](examples/complete) - Advanced usage of the module
- [Simple](examples/simple) - Basic usage of the module

## Breaking changes in v2.x of the module

Due to breaking changes in Snowflake provider and additional code optimizations, **breaking changes** were introduced in `v2.0.0` version of this module.

List of code and variable (API) changes:

- Switched to `snowflake_database_role` module to leverage new `database_roles` mechanism
- stage module version was updated (`v2.1.0`) to use newly introduced changes by Snowflake provider
- overhaul of `roles` and `stages` variables
- variable `add_grants_to_existing_objects` was removed as it is no longer needed

When upgrading from `v1.x`, expect most of the resources to be recreated - if recreation is impossible, then it is possible to import some existing resources.

For more information, refer to [variables.tf](variables.tf), list of inputs below and Snowflake provider documentation

## Breaking changes in v3.x of the module

Due to replacement of nulllabel (`context.tf`) with context provider, some **breaking changes** were introduced in `v3.0.0` version of this module.

List od code and variable (API) changes:

- Removed `context.tf` file (a single-file module with additonal variables), which implied a removal of all its variables (except `name`):
  - `descriptor_formats`
  - `label_value_case`
  - `label_key_case`
  - `id_length_limit`
  - `regex_replace_chars`
  - `label_order`
  - `additional_tag_map`
  - `tags`
  - `labels_as_tags`
  - `attributes`
  - `delimiter`
  - `stage`
  - `environment`
  - `tenant`
  - `namespace`
  - `enabled`
  - `context`
- Remove support `enabled` flag - that might cause some backward compatibility issues with terraform state (please take into account that proper `move` clauses were added to minimize the impact), but proceed with caution
- Additional `context` provider configuration
- New variables were added, to allow naming configuration via `context` provider:
  - `context_templates`
  - `name_schema`

<!-- BEGIN_TF_DOCS -->




## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_catalog"></a> [catalog](#input\_catalog) | Parameter that specifies the default catalog to use for Iceberg tables. | `string` | `null` | no |
| <a name="input_comment"></a> [comment](#input\_comment) | Specifies a comment for the schema | `string` | `null` | no |
| <a name="input_context_templates"></a> [context\_templates](#input\_context\_templates) | Map of context templates used for naming conventions - this variable supersedes `naming_scheme.properties` and `naming_scheme.delimiter` configuration | `map(string)` | `{}` | no |
| <a name="input_create_default_roles"></a> [create\_default\_roles](#input\_create\_default\_roles) | Whether the default database roles should be created | `bool` | `false` | no |
| <a name="input_data_retention_time_in_days"></a> [data\_retention\_time\_in\_days](#input\_data\_retention\_time\_in\_days) | Specifies the number of days for which Time Travel actions (CLONE and UNDROP) can be performed on the schema,<br/>    as well as specifying the default Time Travel retention time for all tables created in the schema | `number` | `1` | no |
| <a name="input_database"></a> [database](#input\_database) | Database where the schema should be created | `string` | n/a | yes |
| <a name="input_default_ddl_collation"></a> [default\_ddl\_collation](#input\_default\_ddl\_collation) | Specifies a default collation specification for all schemas and tables added to the database.<br/>It can be overridden on schema or table level. | `string` | `null` | no |
| <a name="input_enable_console_output"></a> [enable\_console\_output](#input\_enable\_console\_output) | Enables console output for user tasks. | `bool` | `null` | no |
| <a name="input_external_volume"></a> [external\_volume](#input\_external\_volume) | Parameter that specifies the default external volume to use for Iceberg tables. | `string` | `null` | no |
| <a name="input_is_transient"></a> [is\_transient](#input\_is\_transient) | Specifies a schema as transient.<br/>    Transient schemas do not have a Fail-safe period so they do not incur additional storage costs once they leave Time Travel; <br/>    however, this means they are also not protected by Fail-safe in the event of a data loss. | `bool` | `false` | no |
| <a name="input_log_level"></a> [log\_level](#input\_log\_level) | Specifies the severity level of messages that should be ingested and made available in the active event table.<br/>Valid options are: [TRACE DEBUG INFO WARN ERROR FATAL OFF].<br/>Messages at the specified level (and at more severe levels) are ingested. | `string` | `null` | no |
| <a name="input_max_data_extension_time_in_days"></a> [max\_data\_extension\_time\_in\_days](#input\_max\_data\_extension\_time\_in\_days) | Object parameter that specifies the maximum number of days for which Snowflake can extend the data retention period <br/>for tables in the database to prevent streams on the tables from becoming stale. | `number` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the resource | `string` | n/a | yes |
| <a name="input_name_scheme"></a> [name\_scheme](#input\_name\_scheme) | Naming scheme configuration for the resource. This configuration is used to generate names using context provider:<br/>    - `properties` - list of properties to use when creating the name - is superseded by `var.context_templates`<br/>    - `delimiter` - delimited used to create the name from `properties` - is superseded by `var.context_templates`<br/>    - `context_template_name` - name of the context template used to create the name<br/>    - `replace_chars_regex` - regex to use for replacing characters in property-values created by the provider - any characters that match the regex will be removed from the name<br/>    - `extra_values` - map of extra label-value pairs, used to create a name<br/>    - `uppercase` - convert name to uppercase | <pre>object({<br/>    properties            = optional(list(string), ["name"])<br/>    delimiter             = optional(string, "_")<br/>    context_template_name = optional(string, "snowflake-schema")<br/>    replace_chars_regex   = optional(string, "[^a-zA-Z0-9_]")<br/>    extra_values          = optional(map(string))<br/>    uppercase             = optional(bool, true)<br/>  })</pre> | `{}` | no |
| <a name="input_pipe_execution_paused"></a> [pipe\_execution\_paused](#input\_pipe\_execution\_paused) | Pauses the execution of a pipe. | `bool` | `null` | no |
| <a name="input_quoted_identifiers_ignore_case"></a> [quoted\_identifiers\_ignore\_case](#input\_quoted\_identifiers\_ignore\_case) | If true, the case of quoted identifiers is ignored. | `bool` | `null` | no |
| <a name="input_replace_invalid_characters"></a> [replace\_invalid\_characters](#input\_replace\_invalid\_characters) | Specifies whether to replace invalid UTF-8 characters with the Unicode replacement character () in query results for an Iceberg table.<br/>You can only set this parameter for tables that use an external Iceberg catalog. | `bool` | `null` | no |
| <a name="input_roles"></a> [roles](#input\_roles) | Database roles created in the scheme scope | <pre>map(object({<br/>    name_scheme = optional(object({<br/>      properties            = optional(list(string))<br/>      delimiter             = optional(string)<br/>      context_template_name = optional(string)<br/>      replace_chars_regex   = optional(string)<br/>      extra_labels          = optional(map(string))<br/>      uppercase             = optional(bool)<br/>    }))<br/>    role_ownership_grant      = optional(string)<br/>    granted_to_roles          = optional(list(string))<br/>    granted_to_database_roles = optional(list(string))<br/>    granted_database_roles    = optional(list(string))<br/>    schema_grants = optional(list(object({<br/>      all_privileges    = optional(bool)<br/>      with_grant_option = optional(bool, false)<br/>      privileges        = optional(list(string), null)<br/>    })))<br/>    schema_objects_grants = optional(map(list(object({<br/>      all_privileges    = optional(bool)<br/>      with_grant_option = optional(bool)<br/>      privileges        = optional(list(string), null)<br/>      object_name       = optional(string)<br/>      on_all            = optional(bool, false)<br/>      on_future         = optional(bool, false)<br/>    }))), {})<br/>  }))</pre> | `{}` | no |
| <a name="input_skip_schema_creation"></a> [skip\_schema\_creation](#input\_skip\_schema\_creation) | Should schema creation be skipped but allow all other resources to be created.<br/>    Useful if schema already exsists but you want to add e.g. access roles." | `bool` | `false` | no |
| <a name="input_stages"></a> [stages](#input\_stages) | Stages to be created in the schema | <pre>map(object({<br/>    name_scheme = optional(object({<br/>      properties            = optional(list(string))<br/>      delimiter             = optional(string)<br/>      context_template_name = optional(string)<br/>      replace_chars_regex   = optional(string)<br/>      extra_labels          = optional(map(string))<br/>      uppercase             = optional(bool)<br/>    }))<br/>    aws_external_id      = optional(string)<br/>    comment              = optional(string)<br/>    copy_options         = optional(string)<br/>    credentials          = optional(string)<br/>    directory            = optional(string)<br/>    encryption           = optional(string)<br/>    file_format          = optional(string)<br/>    snowflake_iam_user   = optional(string)<br/>    storage_integration  = optional(string)<br/>    url                  = optional(string)<br/>    create_default_roles = optional(bool)<br/>    roles = optional(map(object({<br/>      name_scheme = optional(object({<br/>        properties            = optional(list(string))<br/>        delimiter             = optional(string)<br/>        context_template_name = optional(string)<br/>        replace_chars_regex   = optional(string)<br/>        extra_labels          = optional(map(string))<br/>        uppercase             = optional(bool)<br/>      }))<br/>      with_grant_option         = optional(bool)<br/>      granted_to_roles          = optional(list(string))<br/>      granted_to_database_roles = optional(list(string))<br/>      granted_database_roles    = optional(list(string))<br/>      stage_grants              = optional(list(string))<br/>      all_privileges            = optional(bool)<br/>    })), {})<br/>  }))</pre> | `{}` | no |
| <a name="input_storage_serialization_policy"></a> [storage\_serialization\_policy](#input\_storage\_serialization\_policy) | The storage serialization policy for Iceberg tables that use Snowflake as the catalog.<br/>Valid options are: [COMPATIBLE OPTIMIZED]. | `string` | `null` | no |
| <a name="input_suspend_task_after_num_failures"></a> [suspend\_task\_after\_num\_failures](#input\_suspend\_task\_after\_num\_failures) | How many times a task must fail in a row before it is automatically suspended. 0 disables auto-suspending. | `number` | `null` | no |
| <a name="input_task_auto_retry_attempts"></a> [task\_auto\_retry\_attempts](#input\_task\_auto\_retry\_attempts) | Maximum automatic retries allowed for a user task. | `number` | `null` | no |
| <a name="input_trace_level"></a> [trace\_level](#input\_trace\_level) | Controls how trace events are ingested into the event table.<br/>Valid options are: [ALWAYS ON\_EVENT OFF]." | `string` | `null` | no |
| <a name="input_user_task_managed_initial_warehouse_size"></a> [user\_task\_managed\_initial\_warehouse\_size](#input\_user\_task\_managed\_initial\_warehouse\_size) | The initial size of warehouse to use for managed warehouses in the absence of history. | `string` | `null` | no |
| <a name="input_user_task_minimum_trigger_interval_in_seconds"></a> [user\_task\_minimum\_trigger\_interval\_in\_seconds](#input\_user\_task\_minimum\_trigger\_interval\_in\_seconds) | Minimum amount of time between Triggered Task executions in seconds. | `number` | `null` | no |
| <a name="input_user_task_timeout_ms"></a> [user\_task\_timeout\_ms](#input\_user\_task\_timeout\_ms) | User task execution timeout in milliseconds. | `number` | `null` | no |
| <a name="input_with_managed_access"></a> [with\_managed\_access](#input\_with\_managed\_access) | Specifies a managed schema. Managed access schemas centralize privilege management with the schema owner | `bool` | `false` | no |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_roles_deep_merge"></a> [roles\_deep\_merge](#module\_roles\_deep\_merge) | Invicton-Labs/deepmerge/null | 0.1.5 |
| <a name="module_snowflake_custom_role"></a> [snowflake\_custom\_role](#module\_snowflake\_custom\_role) | getindata/database-role/snowflake | 2.1.0 |
| <a name="module_snowflake_default_role"></a> [snowflake\_default\_role](#module\_snowflake\_default\_role) | getindata/database-role/snowflake | 2.1.0 |
| <a name="module_snowflake_stage"></a> [snowflake\_stage](#module\_snowflake\_stage) | getindata/stage/snowflake | 3.1.1 |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_database"></a> [database](#output\_database) | Database where the schema is deployed to |
| <a name="output_database_roles"></a> [database\_roles](#output\_database\_roles) | Snowflake Database Roles |
| <a name="output_name"></a> [name](#output\_name) | Name of the schema |
| <a name="output_schema_catalog"></a> [schema\_catalog](#output\_schema\_catalog) | Catalog for the schema |
| <a name="output_schema_comment"></a> [schema\_comment](#output\_schema\_comment) | Comment of the schema |
| <a name="output_schema_data_retention_time_in_days"></a> [schema\_data\_retention\_time\_in\_days](#output\_schema\_data\_retention\_time\_in\_days) | Data retention time in days for the schema |
| <a name="output_schema_database"></a> [schema\_database](#output\_schema\_database) | Database where the schema is deployed to |
| <a name="output_schema_default_ddl_collation"></a> [schema\_default\_ddl\_collation](#output\_schema\_default\_ddl\_collation) | Default DDL collation for the schema |
| <a name="output_schema_enable_console_output"></a> [schema\_enable\_console\_output](#output\_schema\_enable\_console\_output) | Whether to enable console output for the schema |
| <a name="output_schema_external_volume"></a> [schema\_external\_volume](#output\_schema\_external\_volume) | External volume for the schema |
| <a name="output_schema_is_transient"></a> [schema\_is\_transient](#output\_schema\_is\_transient) | Is the schema transient |
| <a name="output_schema_log_level"></a> [schema\_log\_level](#output\_schema\_log\_level) | Log level for the schema |
| <a name="output_schema_max_data_extension_time_in_days"></a> [schema\_max\_data\_extension\_time\_in\_days](#output\_schema\_max\_data\_extension\_time\_in\_days) | Maximum data extension time in days for the schema |
| <a name="output_schema_pipe_execution_paused"></a> [schema\_pipe\_execution\_paused](#output\_schema\_pipe\_execution\_paused) | Whether to pause pipe execution for the schema |
| <a name="output_schema_quoted_identifiers_ignore_case"></a> [schema\_quoted\_identifiers\_ignore\_case](#output\_schema\_quoted\_identifiers\_ignore\_case) | Whether to ignore case for quoted identifiers for the schema |
| <a name="output_schema_replace_invalid_characters"></a> [schema\_replace\_invalid\_characters](#output\_schema\_replace\_invalid\_characters) | Whether to replace invalid characters for the schema |
| <a name="output_schema_storage_serialization_policy"></a> [schema\_storage\_serialization\_policy](#output\_schema\_storage\_serialization\_policy) | Storage serialization policy for the schema |
| <a name="output_schema_suspend_task_after_num_failures"></a> [schema\_suspend\_task\_after\_num\_failures](#output\_schema\_suspend\_task\_after\_num\_failures) | Number of task failures after which to suspend the task for the schema |
| <a name="output_schema_task_auto_retry_attempts"></a> [schema\_task\_auto\_retry\_attempts](#output\_schema\_task\_auto\_retry\_attempts) | Number of task auto retry attempts for the schema |
| <a name="output_schema_trace_level"></a> [schema\_trace\_level](#output\_schema\_trace\_level) | Trace level for the schema |
| <a name="output_schema_user_task_managed_initial_warehouse_size"></a> [schema\_user\_task\_managed\_initial\_warehouse\_size](#output\_schema\_user\_task\_managed\_initial\_warehouse\_size) | User task managed initial warehouse size for the schema |
| <a name="output_schema_user_task_minimum_trigger_interval_in_seconds"></a> [schema\_user\_task\_minimum\_trigger\_interval\_in\_seconds](#output\_schema\_user\_task\_minimum\_trigger\_interval\_in\_seconds) | User task minimum trigger interval in seconds for the schema |
| <a name="output_schema_user_task_timeout_ms"></a> [schema\_user\_task\_timeout\_ms](#output\_schema\_user\_task\_timeout\_ms) | User task timeout in milliseconds for the schema |
| <a name="output_schema_with_managed_access"></a> [schema\_with\_managed\_access](#output\_schema\_with\_managed\_access) | Whether the schema has managed access |
| <a name="output_stages"></a> [stages](#output\_stages) | Schema stages |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_context"></a> [context](#provider\_context) | >=0.4.0 |
| <a name="provider_snowflake"></a> [snowflake](#provider\_snowflake) | >= 0.95 |

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_context"></a> [context](#requirement\_context) | >=0.4.0 |
| <a name="requirement_snowflake"></a> [snowflake](#requirement\_snowflake) | >= 0.95 |

## Resources

| Name | Type |
|------|------|
| [snowflake_schema.this](https://registry.terraform.io/providers/Snowflake-Labs/snowflake/latest/docs/resources/schema) | resource |
| [context_label.this](https://registry.terraform.io/providers/cloudposse/context/latest/docs/data-sources/label) | data source |
<!-- END_TF_DOCS -->

## CONTRIBUTING

Contributions are very welcomed!

Start by reviewing [contribution guide](CONTRIBUTING.md) and our [code of conduct](CODE_OF_CONDUCT.md). After that, start coding and ship your changes by creating a new PR.

## LICENSE

Apache 2 Licensed. See [LICENSE](LICENSE) for full details.

## AUTHORS

<!--- Replace repository name -->
<a href="https://github.com/getindata/REPO_NAME/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=getindata/terraform-snowflake-schema" />
</a>

Made with [contrib.rocks](https://contrib.rocks).
