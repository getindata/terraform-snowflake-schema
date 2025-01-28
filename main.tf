data "context_label" "this" {
  delimiter  = local.context_template == null ? var.name_scheme.delimiter : null
  properties = local.context_template == null ? var.name_scheme.properties : null
  template   = local.context_template

  replace_chars_regex = var.name_scheme.replace_chars_regex

  values = merge(
    var.name_scheme.extra_values,
    { name = var.name }
  )
}

resource "snowflake_schema" "this" {
  count = var.skip_schema_creation ? 0 : 1

  name    = var.name_scheme.uppercase ? upper(data.context_label.this.rendered) : data.context_label.this.rendered
  comment = var.comment

  database     = var.database
  is_transient = var.is_transient

  data_retention_time_in_days                   = var.data_retention_time_in_days
  with_managed_access                           = var.with_managed_access
  max_data_extension_time_in_days               = var.max_data_extension_time_in_days
  external_volume                               = var.external_volume
  catalog                                       = var.catalog
  replace_invalid_characters                    = var.replace_invalid_characters
  default_ddl_collation                         = var.default_ddl_collation
  storage_serialization_policy                  = var.storage_serialization_policy
  log_level                                     = var.log_level
  trace_level                                   = var.trace_level
  suspend_task_after_num_failures               = var.suspend_task_after_num_failures
  task_auto_retry_attempts                      = var.task_auto_retry_attempts
  user_task_managed_initial_warehouse_size      = var.user_task_managed_initial_warehouse_size
  user_task_timeout_ms                          = var.user_task_timeout_ms
  user_task_minimum_trigger_interval_in_seconds = var.user_task_minimum_trigger_interval_in_seconds
  quoted_identifiers_ignore_case                = var.quoted_identifiers_ignore_case
  enable_console_output                         = var.enable_console_output
  pipe_execution_paused                         = var.pipe_execution_paused
}

module "snowflake_stage" {
  for_each = var.stages

  source  = "getindata/stage/snowflake"
  version = "3.1.1"

  context_templates = var.context_templates

  name = each.key
  name_scheme = merge({
    uppercase = var.name_scheme.uppercase
    extra_values = {
      database = var.database
      schema   = var.name
    } },
    lookup(each.value, "name_scheme", {})
  )

  schema   = local.schema_name
  database = var.database

  aws_external_id     = each.value.aws_external_id
  comment             = each.value.comment
  copy_options        = each.value.copy_options
  credentials         = each.value.credentials
  directory           = each.value.directory
  encryption          = each.value.encryption
  file_format         = each.value.file_format
  snowflake_iam_user  = each.value.snowflake_iam_user
  storage_integration = each.value.storage_integration
  url                 = each.value.url
  roles               = each.value.roles

  create_default_roles = coalesce(each.value.create_default_roles, var.create_default_roles)
}

module "snowflake_default_role" {
  for_each = local.default_roles

  source  = "getindata/database-role/snowflake"
  version = "2.1.0"

  database_name     = var.database
  context_templates = var.context_templates

  name = each.key
  name_scheme = merge(
    local.default_role_naming_scheme,
    lookup(each.value, "name_scheme", {})
  )

  granted_to_roles          = lookup(each.value, "granted_to_roles", [])
  granted_to_database_roles = lookup(each.value, "granted_to_database_roles", [])
  granted_database_roles    = lookup(each.value, "granted_database_roles", [])
  schema_grants             = lookup(each.value, "schema_grants", [])
  schema_objects_grants     = lookup(each.value, "schema_objects_grants", {})
}

module "snowflake_custom_role" {
  for_each = local.custom_roles

  source  = "getindata/database-role/snowflake"
  version = "2.1.0"

  database_name     = var.database
  context_templates = var.context_templates

  name = each.key
  name_scheme = merge(
    local.default_role_naming_scheme,
    lookup(each.value, "name_scheme", {})
  )

  granted_to_roles          = lookup(each.value, "granted_to_roles", [])
  granted_to_database_roles = lookup(each.value, "granted_to_database_roles", [])
  granted_database_roles    = lookup(each.value, "granted_database_roles", [])
  schema_grants             = lookup(each.value, "schema_grants", [])
  schema_objects_grants     = lookup(each.value, "schema_objects_grants", {})
}
