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

* Creates Snowflake schema
* Can create custom Snowflake database roles with role-to-role assignments
* Can create a set of default database roles to simplify access management:
  * `READONLY` - granted select on all tables and views and usage on some objects in the schema
  * `READWRITE` - granted write type grants on tables and stages. Additionally, allows calling procedures and tasks in the schema
  * `TRANSFORMER` - Allows creating tables and views on top of the `READWRITE` role privileges
  * `ADMIN` - Full access, including setting schema options like `data_retention_days`
  * Each role can be disabled seperately by setting `enabled` to false - see [Complete example](examples/complete)
  * Each role can be additionally modified - see [Complete example](examples/complete)

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
- Logic responsible for creating roles was removed
- `default_roles` and `custom_roles` are now combined and controlled by single logic
- stage module version was updated (`>= v2.0.1`) to use newly introduced changes by Snowflake provider
- overhaul of `roles` and `stages` variables
- variable `add_grants_to_existing_objects` was removed as it is no longer needed


When upgrading from `v1.x`, expect most of the resources to be recreated - if recreation is impossible, then it is possible to import some existing resources.

For more information, refer to [variables.tf](variables.tf), list of inputs below and Snowflake provider documentation

<!-- BEGIN_TF_DOCS -->




## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_tag_map"></a> [additional\_tag\_map](#input\_additional\_tag\_map) | Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br>This is for some rare cases where resources want additional configuration of tags<br>and therefore take a list of maps with tag key, value, and additional configuration. | `map(string)` | `{}` | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br>in the order they appear in the list. New attributes are appended to the<br>end of the list. The elements of the list are joined by the `delimiter`<br>and treated as a single ID element. | `list(string)` | `[]` | no |
| <a name="input_catalog"></a> [catalog](#input\_catalog) | The database parameter that specifies the default catalog to use for Iceberg tables. | `string` | `null` | no |
| <a name="input_comment"></a> [comment](#input\_comment) | Specifies a comment for the schema | `string` | `null` | no |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br>See description of individual variables for details.<br>Leave string and numeric variables as `null` to use default value.<br>Individual variable settings (non-null) override settings in context object,<br>except for attributes, tags, and additional\_tag\_map, which are merged. | `any` | <pre>{<br>  "additional_tag_map": {},<br>  "attributes": [],<br>  "delimiter": null,<br>  "descriptor_formats": {},<br>  "enabled": true,<br>  "environment": null,<br>  "id_length_limit": null,<br>  "label_key_case": null,<br>  "label_order": [],<br>  "label_value_case": null,<br>  "labels_as_tags": [<br>    "unset"<br>  ],<br>  "name": null,<br>  "namespace": null,<br>  "regex_replace_chars": null,<br>  "stage": null,<br>  "tags": {},<br>  "tenant": null<br>}</pre> | no |
| <a name="input_create_default_roles"></a> [create\_default\_roles](#input\_create\_default\_roles) | Whether the default database roles should be created | `bool` | `false` | no |
| <a name="input_data_retention_time_in_days"></a> [data\_retention\_time\_in\_days](#input\_data\_retention\_time\_in\_days) | "Specifies the number of days for which Time Travel actions (CLONE and UNDROP) can be performed on the schema, <br>    as well as specifying the default Time Travel retention time for all tables created in the schema" | `number` | `1` | no |
| <a name="input_database"></a> [database](#input\_database) | Database where the schema should be created | `string` | n/a | yes |
| <a name="input_default_ddl_collation"></a> [default\_ddl\_collation](#input\_default\_ddl\_collation) | Specifies a default collation specification for all schemas and tables added to the database.<br>It can be overridden on schema or table level. | `string` | `null` | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between ID elements.<br>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| <a name="input_descriptor_formats"></a> [descriptor\_formats](#input\_descriptor\_formats) | Describe additional descriptors to be output in the `descriptors` output map.<br>Map of maps. Keys are names of descriptors. Values are maps of the form<br>`{<br>   format = string<br>   labels = list(string)<br>}`<br>(Type is `any` so the map values can later be enhanced to provide additional options.)<br>`format` is a Terraform format string to be passed to the `format()` function.<br>`labels` is a list of labels, in order, to pass to `format()` function.<br>Label values will be normalized before being passed to `format()` so they will be<br>identical to how they appear in `id`.<br>Default is `{}` (`descriptors` output will be empty). | `any` | `{}` | no |
| <a name="input_descriptor_name"></a> [descriptor\_name](#input\_descriptor\_name) | Name of the descriptor used to form a resource name | `string` | `"snowflake-schema"` | no |
| <a name="input_enable_console_output"></a> [enable\_console\_output](#input\_enable\_console\_output) | Enables console output for user tasks. | `bool` | `false` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| <a name="input_external_volume"></a> [external\_volume](#input\_external\_volume) | The database parameter that specifies the default external volume to use for Iceberg tables. | `string` | `null` | no |
| <a name="input_id_length_limit"></a> [id\_length\_limit](#input\_id\_length\_limit) | Limit `id` to this many characters (minimum 6).<br>Set to `0` for unlimited length.<br>Set to `null` for keep the existing setting, which defaults to `0`.<br>Does not affect `id_full`. | `number` | `null` | no |
| <a name="input_is_transient"></a> [is\_transient](#input\_is\_transient) | "Specifies a schema as transient. <br>    Transient schemas do not have a Fail-safe period so they do not incur additional storage costs once they leave Time Travel; <br>    however, this means they are also not protected by Fail-safe in the event of a data loss" | `bool` | `false` | no |
| <a name="input_label_key_case"></a> [label\_key\_case](#input\_label\_key\_case) | Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br>Does not affect keys of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper`.<br>Default value: `title`. | `string` | `null` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | The order in which the labels (ID elements) appear in the `id`.<br>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br>You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present. | `list(string)` | `null` | no |
| <a name="input_label_value_case"></a> [label\_value\_case](#input\_label\_value\_case) | Controls the letter case of ID elements (labels) as included in `id`,<br>set as tag values, and output by this module individually.<br>Does not affect values of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br>Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br>Default value: `lower`. | `string` | `null` | no |
| <a name="input_labels_as_tags"></a> [labels\_as\_tags](#input\_labels\_as\_tags) | Set of labels (ID elements) to include as tags in the `tags` output.<br>Default is to include all labels.<br>Tags with empty values will not be included in the `tags` output.<br>Set to `[]` to suppress all generated tags.<br>**Notes:**<br>  The value of the `name` tag, if included, will be the `id`, not the `name`.<br>  Unlike other `null-label` inputs, the initial setting of `labels_as_tags` cannot be<br>  changed in later chained modules. Attempts to change it will be silently ignored. | `set(string)` | <pre>[<br>  "default"<br>]</pre> | no |
| <a name="input_log_level"></a> [log\_level](#input\_log\_level) | Specifies the severity level of messages that should be ingested and made available in the active event table.<br>Valid options are: [TRACE DEBUG INFO WARN ERROR FATAL OFF].<br>Messages at the specified level (and at more severe levels) are ingested. | `string` | `null` | no |
| <a name="input_max_data_extension_time_in_days"></a> [max\_data\_extension\_time\_in\_days](#input\_max\_data\_extension\_time\_in\_days) | Object parameter that specifies the maximum number of days for which Snowflake can extend the data retention period <br>for tables in the database to prevent streams on the tables from becoming stale. | `number` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br>This is the only ID element not also included as a `tag`.<br>The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input. | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique | `string` | `null` | no |
| <a name="input_pipe_execution_paused"></a> [pipe\_execution\_paused](#input\_pipe\_execution\_paused) | Pauses the execution of a pipe. | `bool` | `false` | no |
| <a name="input_quoted_identifiers_ignore_case"></a> [quoted\_identifiers\_ignore\_case](#input\_quoted\_identifiers\_ignore\_case) | If true, the case of quoted identifiers is ignored. | `bool` | `null` | no |
| <a name="input_regex_replace_chars"></a> [regex\_replace\_chars](#input\_regex\_replace\_chars) | Terraform regular expression (regex) string.<br>Characters matching the regex will be removed from the ID elements.<br>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| <a name="input_replace_invalid_characters"></a> [replace\_invalid\_characters](#input\_replace\_invalid\_characters) | Specifies whether to replace invalid UTF-8 characters with the Unicode replacement character () in query results for an Iceberg table.<br>You can only set this parameter for tables that use an external Iceberg catalog. | `bool` | `null` | no |
| <a name="input_roles"></a> [roles](#input\_roles) | Database roles created in the scheme scope | <pre>map(object({<br>    enabled                   = optional(bool, true)<br>    role_ownership_grant      = optional(string)<br>    granted_to_roles          = optional(list(string))<br>    granted_to_database_roles = optional(list(string))<br>    granted_database_roles    = optional(list(string))<br>    database_grants = optional(object({<br>      all_privileges    = optional(bool)<br>      with_grant_option = optional(bool, false)<br>      privileges        = optional(list(string), null)<br>    }))<br>    schema_grants = optional(list(object({<br>      all_privileges             = optional(bool)<br>      with_grant_option          = optional(bool, false)<br>      privileges                 = optional(list(string), null)<br>      all_schemas_in_database    = optional(bool, false)<br>      future_schemas_in_database = optional(bool, false)<br>      schema_name                = optional(string, null)<br>    })))<br>    schema_objects_grants = optional(map(list(object({<br>      all_privileges    = optional(bool)<br>      with_grant_option = optional(bool)<br>      privileges        = optional(list(string), null)<br>      object_name       = optional(string)<br>      on_all            = optional(bool, false)<br>      schema_name       = optional(string)<br>      on_future         = optional(bool, false)<br>    }))), {})<br>  }))</pre> | `{}` | no |
| <a name="input_skip_schema_creation"></a> [skip\_schema\_creation](#input\_skip\_schema\_creation) | "Should schema creation be skipped but allow all other resources to be created. <br>    Useful if schema already exsists but you want to add e.g. access roles" | `bool` | `false` | no |
| <a name="input_stage"></a> [stage](#input\_stage) | ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release' | `string` | `null` | no |
| <a name="input_stages"></a> [stages](#input\_stages) | Stages to be created in the schema | <pre>map(object({<br>    enabled             = optional(bool, true)<br>    descriptor_name     = optional(string, "snowflake-stage")<br>    aws_external_id     = optional(string)<br>    comment             = optional(string)<br>    copy_options        = optional(string)<br>    credentials         = optional(string)<br>    directory           = optional(string)<br>    encryption          = optional(string)<br>    file_format         = optional(string)<br>    snowflake_iam_user  = optional(string)<br>    storage_integration = optional(string)<br>    url                 = optional(string)<br>    roles = optional(map(object({<br>      with_grant_option         = optional(bool)<br>      granted_to_roles          = optional(list(string))<br>      granted_to_database_roles = optional(list(string))<br>      granted_database_roles    = optional(list(string))<br>      stage_grants              = optional(list(string))<br>      all_privileges            = optional(bool)<br>      on_all                    = optional(bool, false)<br>      schema_name               = optional(string)<br>      on_future                 = optional(bool, false)<br>    })), ({}))<br>    create_default_stage_roles = optional(bool, false)<br>  }))</pre> | `{}` | no |
| <a name="input_storage_serialization_policy"></a> [storage\_serialization\_policy](#input\_storage\_serialization\_policy) | The storage serialization policy for Iceberg tables that use Snowflake as the catalog.<br>Valid options are: [COMPATIBLE OPTIMIZED]. | `string` | `"COMPATIBLE"` | no |
| <a name="input_suspend_task_after_num_failures"></a> [suspend\_task\_after\_num\_failures](#input\_suspend\_task\_after\_num\_failures) | How many times a task must fail in a row before it is automatically suspended. 0 disables auto-suspending. | `number` | `10` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br>Neither the tag keys nor the tag values will be modified by this module. | `map(string)` | `{}` | no |
| <a name="input_task_auto_retry_attempts"></a> [task\_auto\_retry\_attempts](#input\_task\_auto\_retry\_attempts) | Maximum automatic retries allowed for a user task. | `number` | `10` | no |
| <a name="input_tenant"></a> [tenant](#input\_tenant) | ID element \_(Rarely used, not included by default)\_. A customer identifier, indicating who this instance of a resource is for | `string` | `null` | no |
| <a name="input_trace_level"></a> [trace\_level](#input\_trace\_level) | Controls how trace events are ingested into the event table.<br>Valid options are: [ALWAYS ON\_EVENT OFF]." | `string` | `"ALWAYS"` | no |
| <a name="input_user_task_managed_initial_warehouse_size"></a> [user\_task\_managed\_initial\_warehouse\_size](#input\_user\_task\_managed\_initial\_warehouse\_size) | The initial size of warehouse to use for managed warehouses in the absence of history. | `string` | `"LARGE"` | no |
| <a name="input_user_task_minimum_trigger_interval_in_seconds"></a> [user\_task\_minimum\_trigger\_interval\_in\_seconds](#input\_user\_task\_minimum\_trigger\_interval\_in\_seconds) | Minimum amount of time between Triggered Task executions in seconds. | `number` | `120` | no |
| <a name="input_user_task_timeout_ms"></a> [user\_task\_timeout\_ms](#input\_user\_task\_timeout\_ms) | User task execution timeout in milliseconds. | `number` | `3600000` | no |
| <a name="input_with_managed_access"></a> [with\_managed\_access](#input\_with\_managed\_access) | Specifies a managed schema. Managed access schemas centralize privilege management with the schema owner | `bool` | `false` | no |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_roles_deep_merge"></a> [roles\_deep\_merge](#module\_roles\_deep\_merge) | Invicton-Labs/deepmerge/null | 0.1.5 |
| <a name="module_schema_label"></a> [schema\_label](#module\_schema\_label) | cloudposse/label/null | 0.25.0 |
| <a name="module_snowflake_database_role"></a> [snowflake\_database\_role](#module\_snowflake\_database\_role) | getindata/database-role/snowflake | 1.1.0 |
| <a name="module_snowflake_stage"></a> [snowflake\_stage](#module\_snowflake\_stage) | getindata/stage/snowflake | >= 2.0.1 |
| <a name="module_this"></a> [this](#module\_this) | cloudposse/label/null | 0.25.0 |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_database"></a> [database](#output\_database) | Database where the schema is deployed to |
| <a name="output_database_roles"></a> [database\_roles](#output\_database\_roles) | Snowflake Database Roles |
| <a name="output_name"></a> [name](#output\_name) | Name of the schema |
| <a name="output_schema"></a> [schema](#output\_schema) | Details of the schema |
| <a name="output_stages"></a> [stages](#output\_stages) | Schema stages |

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
| [snowflake_schema.this](https://registry.terraform.io/providers/Snowflake-Labs/snowflake/latest/docs/resources/schema) | resource |
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
