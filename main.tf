module "schema_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"
  context = module.this.context

  delimiter           = coalesce(module.this.context.delimiter, "_")
  regex_replace_chars = coalesce(module.this.context.regex_replace_chars, "/[^_a-zA-Z0-9]/")
  label_value_case    = coalesce(module.this.context.label_value_case, "upper")
}

resource "snowflake_schema" "this" {
  count = module.this.enabled && var.skip_schema_creation == false ? 1 : 0

  name    = local.name_from_descriptor
  comment = var.comment

  database            = local.database
  data_retention_days = var.data_retention_days
  is_transient        = var.is_transient
  is_managed          = var.is_managed
}

module "snowflake_stage" {
  for_each = var.stages

  source  = "getindata/stage/snowflake"
  version = "1.0.0"
  context = module.this.context
  enabled = module.this.enabled && each.value.enabled

  name            = each.key
  descriptor_name = each.value.descriptor_name

  schema   = local.schema
  database = local.database

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

  create_default_roles = coalesce(each.value.create_default_roles, var.create_default_roles)
  roles                = each.value.roles
}

module "snowflake_default_role" {
  for_each = local.default_roles

  source  = "getindata/role/snowflake"
  version = "1.3.0"
  context = module.this.context
  enabled = local.create_default_roles && each.value.enabled

  name       = each.key
  attributes = [local.database, local.schema]

  role_ownership_grant = each.value.role_ownership_grant
  granted_to_users     = each.value.granted_to_users
  granted_to_roles     = each.value.granted_to_roles
  granted_roles        = each.value.granted_roles
}


module "snowflake_custom_role" {
  for_each = local.custom_roles

  source  = "getindata/role/snowflake"
  version = "1.3.0"
  context = module.this.context
  enabled = module.this.enabled && each.value.enabled

  name       = each.key
  attributes = [local.database, local.schema]

  role_ownership_grant = each.value.role_ownership_grant
  granted_to_users     = each.value.granted_to_users
  granted_to_roles     = each.value.granted_to_roles
  granted_roles        = each.value.granted_roles
}

resource "snowflake_schema_grant" "this" {
  for_each = module.this.enabled ? local.schema_grants : {}

  database_name = local.database
  schema_name   = local.schema
  privilege     = each.key
  roles         = each.value
}

################################################################

resource "snowflake_table_grant" "this" {
  for_each = module.this.enabled ? local.table_grants : {}

  database_name = local.database
  schema_name   = local.schema
  on_future     = true
  privilege     = each.key
  roles         = each.value
}

resource "snowflake_table_grant" "existing" {
  for_each = module.this.enabled ? local.table_grants_on_existing : {}

  database_name = local.database
  schema_name   = local.schema
  on_all        = true
  privilege     = each.key
  roles         = each.value
}

################################################################

################################################################

resource "snowflake_grant_privileges_to_role" "dynamic_table" {
  for_each = module.this.enabled ? local.dynamic_table_grants : {}

  privileges     = each.value != ["ALL PRIVILEGES"] ? each.value : null
  all_privileges = each.value == ["ALL PRIVILEGES"] ? true : null
  role_name      = each.key

  on_schema_object {
    future {
      object_type_plural = "DYNAMIC TABLES"
      in_schema          = join(".", [local.database, local.schema])
    }
  }
}

resource "snowflake_grant_privileges_to_role" "existing_dynamic_table" {
  for_each = module.this.enabled ? local.dynamic_table_grants_on_existing : {}

  privileges     = each.value != ["ALL PRIVILEGES"] ? each.value : null
  all_privileges = each.value == ["ALL PRIVILEGES"] ? true : null
  role_name      = each.key

  on_schema_object {
    all {
      object_type_plural = "DYNAMIC TABLES"
      in_schema          = join(".", [local.database, local.schema])
    }
  }
}

################################################################

################################################################

resource "snowflake_external_table_grant" "this" {
  for_each = module.this.enabled ? local.external_table_grants : {}

  database_name = local.database
  schema_name   = local.schema
  on_future     = true
  privilege     = each.key
  roles         = each.value
}

resource "snowflake_external_table_grant" "existing" {
  for_each = module.this.enabled ? local.external_table_grants_on_existing : {}

  database_name = local.database
  schema_name   = local.schema
  on_all        = true
  privilege     = each.key
  roles         = each.value
}

################################################################


################################################################

resource "snowflake_view_grant" "this" {
  for_each = module.this.enabled ? local.view_grants : {}

  database_name = local.database
  schema_name   = local.schema
  on_future     = true
  privilege     = each.key
  roles         = each.value
}

resource "snowflake_view_grant" "existing" {
  for_each = module.this.enabled ? local.view_grants_on_existing : {}

  database_name = local.database
  schema_name   = local.schema
  on_all        = true
  privilege     = each.key
  roles         = each.value
}

################################################################



################################################################

resource "snowflake_materialized_view_grant" "this" {
  for_each = module.this.enabled ? local.materialized_view_grants : {}

  database_name = local.database
  schema_name   = local.schema
  on_future     = true
  privilege     = each.key
  roles         = each.value
}

resource "snowflake_materialized_view_grant" "existing" {
  for_each = module.this.enabled ? local.materialized_view_grants_on_existing : {}

  database_name = local.database
  schema_name   = local.schema
  on_all        = true
  privilege     = each.key
  roles         = each.value
}

################################################################

resource "snowflake_file_format_grant" "this" {
  for_each = module.this.enabled ? local.file_format_grants : {}

  database_name = local.database
  schema_name   = local.schema
  on_future     = true
  privilege     = each.key
  roles         = each.value
}

resource "snowflake_file_format_grant" "existing" {
  for_each = module.this.enabled ? local.file_format_grants_on_existing : {}

  database_name = local.database
  schema_name   = local.schema
  on_all        = true
  privilege     = each.key
  roles         = each.value
}

################################################################



################################################################

resource "snowflake_function_grant" "this" {
  for_each = module.this.enabled ? local.function_grants : {}

  database_name = local.database
  schema_name   = local.schema
  on_future     = true
  privilege     = each.key
  roles         = each.value
}

resource "snowflake_function_grant" "existing" {
  for_each = module.this.enabled ? local.function_grants_on_existing : {}

  database_name = local.database
  schema_name   = local.schema
  on_all        = true
  privilege     = each.key
  roles         = each.value
}

################################################################



################################################################

resource "snowflake_stage_grant" "this" {
  for_each = module.this.enabled ? local.stage_grants : {}

  database_name = local.database
  schema_name   = local.schema
  on_future     = true
  privilege     = each.key
  roles         = each.value
}

resource "snowflake_stage_grant" "existing" {
  for_each = module.this.enabled ? local.stage_grants_on_existing : {}

  database_name = local.database
  schema_name   = local.schema
  on_all        = true
  privilege     = each.key
  roles         = each.value
}

################################################################



################################################################

resource "snowflake_task_grant" "this" {
  for_each = module.this.enabled ? local.task_grants : {}

  database_name = local.database
  schema_name   = local.schema
  on_future     = true
  privilege     = each.key
  roles         = each.value
}

resource "snowflake_task_grant" "existing" {
  for_each = module.this.enabled ? local.task_grants_on_existing : {}

  database_name = local.database
  schema_name   = local.schema
  on_all        = true
  privilege     = each.key
  roles         = each.value
}

################################################################



################################################################

resource "snowflake_procedure_grant" "this" {
  for_each = module.this.enabled ? local.procedure_grants : {}

  database_name = local.database
  schema_name   = local.schema
  on_future     = true
  privilege     = each.key
  roles         = each.value
}

resource "snowflake_procedure_grant" "existing" {
  for_each = module.this.enabled ? local.procedure_grants_on_existing : {}

  database_name = local.database
  schema_name   = local.schema
  on_all        = true
  privilege     = each.key
  roles         = each.value
}

################################################################



################################################################

resource "snowflake_sequence_grant" "this" {
  for_each = module.this.enabled ? local.sequence_grants : {}

  database_name = local.database
  schema_name   = local.schema
  on_future     = true
  privilege     = each.key
  roles         = each.value
}

resource "snowflake_sequence_grant" "existing" {
  for_each = module.this.enabled ? local.sequence_grants_on_existing : {}

  database_name = local.database
  schema_name   = local.schema
  on_all        = true
  privilege     = each.key
  roles         = each.value
}

################################################################



################################################################

resource "snowflake_stream_grant" "this" {
  for_each = module.this.enabled ? local.stream_grants : {}

  database_name = local.database
  schema_name   = local.schema
  on_future     = true
  privilege     = each.key
  roles         = each.value
}

resource "snowflake_stream_grant" "existing" {
  for_each = module.this.enabled ? local.stream_grants_on_existing : {}

  database_name = local.database
  schema_name   = local.schema
  on_all        = true
  privilege     = each.key
  roles         = each.value
}
