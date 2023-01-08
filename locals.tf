locals {
  # Get a name from the descriptor. If not available, use default naming convention.
  # Trim and replace function are used to avoid bare delimiters on both ends of the name and situation of adjacent delimiters.
  name_from_descriptor = module.schema_label.enabled ? trim(replace(
    lookup(module.schema_label.descriptors, var.descriptor_name, module.schema_label.id), "/${module.schema_label.delimiter}${module.schema_label.delimiter}+/", module.schema_label.delimiter
  ), module.schema_label.delimiter) : null

  create_default_roles = module.this.enabled && var.create_default_roles
  on_future_grant_key  = "_"

  default_roles_definition = {
    readonly = {
      schema_grants            = ["USAGE"]
      table_grants             = ["SELECT"]
      external_table_grants    = ["SELECT", "REFERENCES"]
      view_grants              = ["SELECT", "REFERENCES"]
      materialized_view_grants = ["SELECT", "REFERENCES"]
      file_format_grants       = ["USAGE"]
      function_grants          = ["USAGE"]
      stage_grants             = ["USAGE"]
      task_grants              = ["MONITOR"]
    }
    read_classified = {}
    readwrite = {
      schema_grants            = ["USAGE"]
      table_grants             = ["SELECT", "INSERT", "UPDATE", "DELETE", "TRUNCATE", "REFERENCES", "REBUILD"]
      external_table_grants    = ["SELECT", "REFERENCES"]
      view_grants              = ["SELECT", "REFERENCES"]
      materialized_view_grants = ["SELECT", "REFERENCES"]
      file_format_grants       = ["USAGE"]
      function_grants          = ["USAGE"]
      stage_grants             = ["USAGE", "READ", "WRITE"]
      task_grants              = ["MONITOR", "OPERATE"]
      procedure_grants         = ["USAGE"]
    }
    admin = {
      schema_grants            = ["MONITOR", "CREATE TEMPORARY TABLE", "CREATE TAG", "CREATE PIPE", "CREATE PROCEDURE", "CREATE MATERIALIZED VIEW", "CREATE ROW ACCESS POLICY", "USAGE", "CREATE TABLE", "CREATE FILE FORMAT", "CREATE STAGE", "CREATE TASK", "CREATE FUNCTION", "CREATE EXTERNAL TABLE", "ADD SEARCH OPTIMIZATION", "MODIFY", "OWNERSHIP", "CREATE SEQUENCE", "CREATE MASKING POLICY", "CREATE VIEW", "CREATE STREAM"]
      table_grants             = ["SELECT", "INSERT", "UPDATE", "DELETE", "TRUNCATE", "REFERENCES", "REBUILD"]
      external_table_grants    = ["SELECT", "REFERENCES"]
      view_grants              = ["SELECT", "REFERENCES"]
      materialized_view_grants = ["SELECT", "REFERENCES"]
      file_format_grants       = ["USAGE"]
      function_grants          = ["USAGE"]
      stage_grants             = ["USAGE", "READ", "WRITE"]
      task_grants              = ["MONITOR", "OPERATE"]
      procedure_grants         = ["USAGE"]
    }
  }

  provided_roles = { for role_name, role in var.roles : role_name => {
    for k, v in role : k => v
    if v != null
  } }
  roles_definition = module.roles_deep_merge.merged

  default_roles = {
    for role_name, role in local.roles_definition : role_name => role
    if contains(keys(local.default_roles_definition), role_name)
  }
  custom_roles = {
    for role_name, role in local.roles_definition : role_name => role
    if !contains(keys(local.default_roles_definition), role_name)
  }

  roles = {
    for role_name, role in merge(
      module.snowflake_default_role,
      module.snowflake_custom_role
    ) : role_name => role
    if role.name != null
  }
}

module "roles_deep_merge" {
  source  = "Invicton-Labs/deepmerge/null"
  version = "0.1.5"

  maps = [local.default_roles_definition, local.provided_roles]
}
