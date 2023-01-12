module "schema_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"
  context = module.this.context

  delimiter           = coalesce(module.this.context.delimiter, "_")
  regex_replace_chars = coalesce(module.this.context.regex_replace_chars, "/[^_a-zA-Z0-9]/")
  label_value_case    = coalesce(module.this.context.label_value_case, "upper")
}

resource "snowflake_schema" "this" {
  count = module.this.enabled ? 1 : 0

  name    = local.name_from_descriptor
  comment = var.comment

  database            = var.database
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

  schema   = one(snowflake_schema.this[*].name)
  database = one(snowflake_schema.this[*].database)

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
  version = "1.0.3"
  context = module.this.context
  enabled = local.create_default_roles && lookup(each.value, "enabled", true)

  name       = each.key
  attributes = [var.database, one(snowflake_schema.this[*].name)]

  role_ownership_grant = lookup(each.value, "role_ownership_grant", "SYSADMIN")
  granted_to_users     = lookup(each.value, "granted_to_users", [])
  granted_to_roles     = lookup(each.value, "granted_to_roles", [])
  granted_roles        = lookup(each.value, "granted_roles", [])
}


module "snowflake_custom_role" {
  for_each = local.custom_roles

  source  = "getindata/role/snowflake"
  version = "1.0.3"
  context = module.this.context
  enabled = module.this.enabled && lookup(each.value, "enabled", true)

  name       = each.key
  attributes = [var.database, one(snowflake_schema.this[*].name)]

  role_ownership_grant = lookup(each.value, "role_ownership_grant", "SYSADMIN")
  granted_to_users     = lookup(each.value, "granted_to_users", [])
  granted_to_roles     = lookup(each.value, "granted_to_roles", [])
  granted_roles        = lookup(each.value, "granted_roles", [])
}

resource "snowflake_schema_grant" "this" {
  for_each = module.this.enabled ? transpose({ for role_name, role in local.roles : local.roles[role_name].name =>
    lookup(local.roles_definition[role_name], "schema_grants", [])
    if lookup(local.roles_definition[role_name], "enabled", true)
  }) : {}

  database_name = var.database
  schema_name   = one(snowflake_schema.this[*].name)
  privilege     = each.key
  roles         = each.value
}

resource "snowflake_table_grant" "this" {
  for_each = module.this.enabled ? transpose({ for role_name, role in local.roles : local.roles[role_name].name =>
    lookup(local.roles_definition[role_name], "table_grants", [])
    if lookup(local.roles_definition[role_name], "enabled", true)
  }) : {}

  database_name = var.database
  schema_name   = one(snowflake_schema.this[*].name)
  on_future     = true
  privilege     = each.key
  roles         = each.value
}

resource "snowflake_external_table_grant" "this" {
  for_each = module.this.enabled ? transpose({ for role_name, role in local.roles : local.roles[role_name].name =>
    lookup(local.roles_definition[role_name], "external_table_grants", [])
    if lookup(local.roles_definition[role_name], "enabled", true)
  }) : {}

  database_name = var.database
  schema_name   = one(snowflake_schema.this[*].name)
  on_future     = true
  privilege     = each.key
  roles         = each.value
}

resource "snowflake_view_grant" "this" {
  for_each = module.this.enabled ? transpose({ for role_name, role in local.roles : local.roles[role_name].name =>
    lookup(local.roles_definition[role_name], "view_grants", [])
    if lookup(local.roles_definition[role_name], "enabled", true)
  }) : {}

  database_name = var.database
  schema_name   = one(snowflake_schema.this[*].name)
  on_future     = true
  privilege     = each.key
  roles         = each.value
}

resource "snowflake_materialized_view_grant" "this" {
  for_each = module.this.enabled ? transpose({ for role_name, role in local.roles : local.roles[role_name].name =>
    lookup(local.roles_definition[role_name], "materialized_view_grants", [])
    if lookup(local.roles_definition[role_name], "enabled", true)
  }) : {}

  database_name = var.database
  schema_name   = one(snowflake_schema.this[*].name)
  on_future     = true
  privilege     = each.key
  roles         = each.value
}

resource "snowflake_file_format_grant" "this" {
  for_each = module.this.enabled ? transpose({ for role_name, role in local.roles : local.roles[role_name].name =>
    lookup(local.roles_definition[role_name], "file_format_grants", [])
    if lookup(local.roles_definition[role_name], "enabled", true)
  }) : {}

  database_name = var.database
  schema_name   = one(snowflake_schema.this[*].name)
  on_future     = true
  privilege     = each.key
  roles         = each.value
}

resource "snowflake_function_grant" "this" {
  for_each = module.this.enabled ? transpose({ for role_name, role in local.roles : local.roles[role_name].name =>
    lookup(local.roles_definition[role_name], "function_grants", [])
    if lookup(local.roles_definition[role_name], "enabled", true)
  }) : {}

  database_name = var.database
  schema_name   = one(snowflake_schema.this[*].name)
  on_future     = true
  privilege     = each.key
  roles         = each.value
}

resource "snowflake_stage_grant" "this" {
  for_each = module.this.enabled ? transpose({ for role_name, role in local.roles : local.roles[role_name].name =>
    lookup(local.roles_definition[role_name], "stage_grants", [])
    if lookup(local.roles_definition[role_name], "enabled", true)
  }) : {}

  database_name = var.database
  schema_name   = one(snowflake_schema.this[*].name)
  on_future     = true
  privilege     = each.key
  roles         = each.value
}

resource "snowflake_task_grant" "this" {
  for_each = module.this.enabled ? transpose({ for role_name, role in local.roles : local.roles[role_name].name =>
    lookup(local.roles_definition[role_name], "task_grants", [])
    if lookup(local.roles_definition[role_name], "enabled", true)
  }) : {}

  database_name = var.database
  schema_name   = one(snowflake_schema.this[*].name)
  on_future     = true
  privilege     = each.key
  roles         = each.value
}

resource "snowflake_procedure_grant" "this" {
  for_each = module.this.enabled ? transpose({ for role_name, role in local.roles : local.roles[role_name].name =>
    lookup(local.roles_definition[role_name], "procedure_grants", [])
    if lookup(local.roles_definition[role_name], "enabled", true)
  }) : {}

  database_name = var.database
  schema_name   = one(snowflake_schema.this[*].name)
  on_future     = true
  privilege     = each.key
  roles         = each.value
}

resource "snowflake_sequence_grant" "this" {
  for_each = module.this.enabled ? transpose({ for role_name, role in local.roles : local.roles[role_name].name =>
    lookup(local.roles_definition[role_name], "sequence_grants", [])
    if lookup(local.roles_definition[role_name], "enabled", true)
  }) : {}

  database_name = var.database
  schema_name   = one(snowflake_schema.this[*].name)
  on_future     = true
  privilege     = each.key
  roles         = each.value
}

resource "snowflake_stream_grant" "this" {
  for_each = module.this.enabled ? transpose({ for role_name, role in local.roles : local.roles[role_name].name =>
    lookup(local.roles_definition[role_name], "stream_grants", [])
    if lookup(local.roles_definition[role_name], "enabled", true)
  }) : {}

  database_name = var.database
  schema_name   = one(snowflake_schema.this[*].name)
  on_future     = true
  privilege     = each.key
  roles         = each.value
}
