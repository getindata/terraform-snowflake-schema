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

module "snowflake_readonly_role" {
  source  = "getindata/role/snowflake"
  version = "1.0.3"
  context = module.this.context
  enabled = module.this.enabled && var.create_default_roles && try(local.roles["readonly"].enabled, true)

  name       = "readonly"
  attributes = [var.database, one(snowflake_schema.this[*].name)]

  role_ownership_grant = try(local.roles["readonly"].role_ownership_grant, "SYSADMIN")
  granted_to_users     = try(local.roles["readonly"].granted_to_users, [])
  granted_to_roles     = try(local.roles["readonly"].granted_to_roles, [])
  granted_roles        = try(local.roles["readonly"].granted_roles, [])
}

module "snowflake_read_classified_role" {
  source  = "getindata/role/snowflake"
  version = "1.0.3"
  context = module.this.context
  enabled = module.this.enabled && var.create_default_roles && try(local.roles["read_classified"].enabled, true)

  name       = "read_classified"
  attributes = [var.database, one(snowflake_schema.this[*].name)]

  role_ownership_grant = try(local.roles["read_classified"].role_ownership_grant, "SYSADMIN")
  granted_to_users     = try(local.roles["read_classified"].granted_to_users, [])
  granted_to_roles     = try(local.roles["read_classified"].granted_to_roles, [])
  granted_roles        = try(local.roles["read_classified"].granted_roles, [])
}

module "snowflake_readwrite_role" {
  source  = "getindata/role/snowflake"
  version = "1.0.3"
  context = module.this.context
  enabled = module.this.enabled && var.create_default_roles && try(local.roles["readwrite"].enabled, true)

  name       = "readwrite"
  attributes = [var.database, one(snowflake_schema.this[*].name)]

  role_ownership_grant = try(local.roles["readwrite"].role_ownership_grant, "SYSADMIN")
  granted_to_users     = try(local.roles["readwrite"].granted_to_users, [])
  granted_to_roles     = try(local.roles["readwrite"].granted_to_roles, [])
  granted_roles        = concat(try(local.roles["readwrite"].granted_roles, []), [module.snowflake_readonly_role.name])
}

module "snowflake_modify_role" {
  source  = "getindata/role/snowflake"
  version = "1.0.3"
  context = module.this.context
  enabled = module.this.enabled && var.create_default_roles && try(local.roles["modify"].enabled, true)

  name       = "modify"
  attributes = [var.database, one(snowflake_schema.this[*].name)]

  role_ownership_grant = try(local.roles["modify"].role_ownership_grant, "SYSADMIN")
  granted_to_users     = try(local.roles["modify"].granted_to_users, [])
  granted_to_roles     = try(local.roles["modify"].granted_to_roles, [])
  granted_roles        = concat(try(local.roles["modify"].granted_roles, []), [module.snowflake_readwrite_role.name])
}

module "snowflake_admin_role" {
  source  = "getindata/role/snowflake"
  version = "1.0.3"
  context = module.this.context
  enabled = module.this.enabled && var.create_default_roles && try(local.roles["admin"].enabled, true)

  name       = "admin"
  attributes = [var.database, one(snowflake_schema.this[*].name)]

  role_ownership_grant = try(local.roles["admin"].role_ownership_grant, "SYSADMIN")
  granted_to_users     = try(local.roles["admin"].granted_to_users, [])
  granted_to_roles     = try(local.roles["admin"].granted_to_roles, [])
  granted_roles        = concat(try(local.roles["admin"].granted_roles, []), [module.snowflake_modify_role.name])
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
  for_each = module.this.enabled ? transpose({ for role_name, role in local.role_modules : local.role_modules[role_name].name =>
    lookup(local.roles[role_name], "schema_grants", { privileges = [] }).privileges
    if lookup(local.roles[role_name], "enabled", true)
  }) : {}

  database_name = var.database
  schema_name   = one(snowflake_schema.this[*].name)
  privilege     = each.key
  roles         = each.value
}

resource "snowflake_table_grant" "this" {
  for_each = module.this.enabled ? transpose({ for role_name, role in local.role_modules : local.role_modules[role_name].name => flatten([
    for grant in lookup(local.roles[role_name], "table_grants", {}) : grant.privileges
    ])
    if lookup(local.roles[role_name], "enabled", true)
  }) : {}

  database_name = var.database
  schema_name   = one(snowflake_schema.this[*].name)
  on_future     = each.key == "_"
  privilege     = each.key
  roles         = each.value
}

resource "snowflake_external_table_grant" "this" {
  for_each = module.this.enabled ? transpose({ for role_name, role in local.role_modules : local.role_modules[role_name].name => flatten([
    for grant in lookup(local.roles[role_name], "external_table_grants", {}) : grant.privileges
    ])
    if lookup(local.roles[role_name], "enabled", true)
  }) : {}

  database_name = var.database
  schema_name   = one(snowflake_schema.this[*].name)
  on_future     = each.key == "_"
  privilege     = each.key
  roles         = each.value
}

resource "snowflake_view_grant" "this" {
  for_each = module.this.enabled ? transpose({ for role_name, role in local.role_modules : local.role_modules[role_name].name => flatten([
    for grant in lookup(local.roles[role_name], "view_grants", {}) : grant.privileges
    ])
    if lookup(local.roles[role_name], "enabled", true)
  }) : {}
  database_name = var.database
  schema_name   = one(snowflake_schema.this[*].name)
  on_future     = each.key == "_"
  privilege     = each.key
  roles         = each.value
}

resource "snowflake_materialized_view_grant" "this" {
  for_each = module.this.enabled ? transpose({ for role_name, role in local.role_modules : local.role_modules[role_name].name => flatten([
    for grant in lookup(local.roles[role_name], "materialized_view_grants", {}) : grant.privileges
    ])
    if lookup(local.roles[role_name], "enabled", true)
  }) : {}

  database_name = var.database
  schema_name   = one(snowflake_schema.this[*].name)
  on_future     = each.key == "_"
  privilege     = each.key
  roles         = each.value
}

resource "snowflake_file_format_grant" "this" {
  for_each = module.this.enabled ? transpose({ for role_name, role in local.role_modules : local.role_modules[role_name].name => flatten([
    for grant in lookup(local.roles[role_name], "file_format_grants", {}) : grant.privileges
    ])
    if lookup(local.roles[role_name], "enabled", true)
  }) : {}

  database_name = var.database
  schema_name   = one(snowflake_schema.this[*].name)
  on_future     = each.key == "_"
  privilege     = each.key
  roles         = each.value
}

resource "snowflake_function_grant" "this" {
  for_each = module.this.enabled ? transpose({ for role_name, role in local.role_modules : local.role_modules[role_name].name => flatten([
    for grant in lookup(local.roles[role_name], "function_grants", {}) : grant.privileges
    ])
    if lookup(local.roles[role_name], "enabled", true)
  }) : {}

  database_name = var.database
  schema_name   = one(snowflake_schema.this[*].name)
  on_future     = each.key == "_"
  privilege     = each.key
  roles         = each.value
}

resource "snowflake_stage_grant" "this" {
  for_each = module.this.enabled ? transpose({ for role_name, role in local.role_modules : local.role_modules[role_name].name => flatten([
    for grant in lookup(local.roles[role_name], "stage_grants", {}) : grant.privileges
    ])
    if lookup(local.roles[role_name], "enabled", true)
  }) : {}

  database_name = var.database
  schema_name   = one(snowflake_schema.this[*].name)
  on_future     = each.key == "_"
  privilege     = each.key
  roles         = each.value
}

resource "snowflake_task_grant" "this" {
  for_each = module.this.enabled ? transpose({ for role_name, role in local.role_modules : local.role_modules[role_name].name => flatten([
    for grant in lookup(local.roles[role_name], "task_grants", {}) : grant.privileges
    ])
    if lookup(local.roles[role_name], "enabled", true)
  }) : {}

  database_name = var.database
  schema_name   = one(snowflake_schema.this[*].name)
  on_future     = each.key == "_"
  privilege     = each.key
  roles         = each.value
}

resource "snowflake_procedure_grant" "this" {
  for_each = module.this.enabled ? transpose({ for role_name, role in local.role_modules : local.role_modules[role_name].name => flatten([
    for grant in lookup(local.roles[role_name], "procedure_grants", {}) : grant.privileges
    ])
    if lookup(local.roles[role_name], "enabled", true)
  }) : {}

  database_name = var.database
  schema_name   = one(snowflake_schema.this[*].name)
  on_future     = each.key == "_"
  privilege     = each.key
  roles         = each.value
}

resource "snowflake_sequence_grant" "this" {
  for_each = module.this.enabled ? transpose({ for role_name, role in local.role_modules : local.role_modules[role_name].name => flatten([
    for grant in lookup(local.roles[role_name], "sequence_grants", {}) : grant.privileges
    ])
    if lookup(local.roles[role_name], "enabled", true)
  }) : {}

  database_name = var.database
  schema_name   = one(snowflake_schema.this[*].name)
  on_future     = each.key == "_"
  privilege     = each.key
  roles         = each.value
}

resource "snowflake_stream_grant" "this" {
  for_each = module.this.enabled ? transpose({ for role_name, role in local.role_modules : local.role_modules[role_name].name => flatten([
    for grant in lookup(local.roles[role_name], "stream_grants", {}) : grant.privileges
    ])
    if lookup(local.roles[role_name], "enabled", true)
  }) : {}

  database_name = var.database
  schema_name   = one(snowflake_schema.this[*].name)
  on_future     = each.key == "_"
  privilege     = each.key
  roles         = each.value
}
