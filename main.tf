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

  database     = local.database
  is_transient = var.is_transient

  data_retention_time_in_days = var.data_retention_time_in_days
  with_managed_access         = var.with_managed_access
}

module "snowflake_stage" {
  for_each = var.stages

  source  = "getindata/stage/snowflake"
  version = "2.0.0"
  enabled = module.this.enabled && each.value.enabled
  context = module.this.context

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
  roles               = each.value.roles

  create_default_database_roles = each.value.create_default_database_roles
}

module "snowflake_database_role" {
  for_each = local.roles

  source  = "getindata/database-role/snowflake"
  version = "1.1.0"
  context = module.this.context

  database_name = one(snowflake_schema.this[*].database)
  name          = each.key
  attributes    = [local.database, local.schema]

  granted_to_roles          = lookup(each.value, "granted_to_roles", [])
  granted_to_database_roles = lookup(each.value, "granted_to_database_roles", [])
  granted_database_roles    = lookup(each.value, "granted_database_roles", [])
  schema_grants             = lookup(each.value, "schema_grants", [])
  schema_objects_grants     = lookup(each.value, "schema_objects_grants", {})
}
