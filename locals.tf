locals {
  # Get a name from the descriptor. If not available, use default naming convention.
  # Trim and replace function are used to avoid bare delimiters on both ends of the name and situation of adjacent delimiters.
  name_from_descriptor = module.schema_label.enabled ? trim(replace(
    lookup(module.schema_label.descriptors, var.descriptor_name, module.schema_label.id), "/${module.schema_label.delimiter}${module.schema_label.delimiter}+/", module.schema_label.delimiter
  ), module.schema_label.delimiter) : null

  create_default_roles = module.this.enabled && var.create_default_roles
  skip_schema_creation = module.this.enabled && var.skip_schema_creation

  #This needs to be the same as an object in roles variable
  role_template = {
    enabled                        = true
    comment                        = null
    role_ownership_grant           = "SYSADMIN"
    granted_roles                  = []
    granted_to_roles               = []
    granted_to_users               = []
    add_grants_to_existing_objects = false
    schema_grants                  = []
    table_grants                   = []
    dynamic_table_grants           = []
    external_table_grants          = []
    view_grants                    = []
    materialized_view_grants       = []
    file_format_grants             = []
    function_grants                = []
    stage_grants                   = []
    task_grants                    = []
    procedure_grants               = []
    sequence_grants                = []
    stream_grants                  = []
  }

  default_roles_definition = {
    readonly = {
      schema_grants            = ["USAGE"]
      table_grants             = ["SELECT"]
      dynamic_table_grants     = ["SELECT"]
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
      dynamic_table_grants     = ["SELECT"]
      external_table_grants    = ["SELECT", "REFERENCES"]
      view_grants              = ["SELECT", "REFERENCES"]
      materialized_view_grants = ["SELECT", "REFERENCES"]
      file_format_grants       = ["USAGE"]
      function_grants          = ["USAGE"]
      stage_grants             = ["USAGE", "READ", "WRITE"]
      task_grants              = ["MONITOR", "OPERATE"]
      procedure_grants         = ["USAGE"]
    }
    transformer = {
      schema_grants            = ["CREATE TEMPORARY TABLE", "CREATE TAG", "CREATE PIPE", "CREATE PROCEDURE", "CREATE MATERIALIZED VIEW", "USAGE", "CREATE TABLE", "CREATE FILE FORMAT", "CREATE STAGE", "CREATE TASK", "CREATE FUNCTION", "CREATE EXTERNAL TABLE", "CREATE SEQUENCE", "CREATE VIEW", "CREATE STREAM"]
      table_grants             = ["SELECT", "INSERT", "UPDATE", "DELETE", "TRUNCATE", "REFERENCES", "REBUILD"]
      dynamic_table_grants     = ["ALL PRIVILEGES"]
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
      schema_grants            = ["ALL PRIVILEGES"]
      table_grants             = ["ALL PRIVILEGES"]
      dynamic_table_grants     = ["ALL PRIVILEGES"]
      external_table_grants    = ["ALL PRIVILEGES"]
      view_grants              = ["ALL PRIVILEGES"]
      materialized_view_grants = ["ALL PRIVILEGES"]
      file_format_grants       = ["ALL PRIVILEGES"]
      function_grants          = ["ALL PRIVILEGES"]
      stage_grants             = ["ALL PRIVILEGES"]
      task_grants              = ["ALL PRIVILEGES"]
      procedure_grants         = ["ALL PRIVILEGES"]
    }
  }

  provided_roles = {
    for role_name, role in var.roles : role_name => {
      for k, v in role : k => v
      if v != null
    }
  }

  roles_definition = {
    for role_name, role in module.roles_deep_merge.merged : role_name => merge(
      local.role_template,
      role
    )
  }

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

  schema   = coalesce(one(snowflake_schema.this[*].name), var.name)
  database = var.database

  schema_grants = transpose(
    {
      for role_name, role in local.roles : local.roles[role_name].name => local.roles_definition[role_name].schema_grants
      if local.roles_definition[role_name].enabled
    }
  )

  table_grants = transpose(
    {
      for role_name, role in local.roles : local.roles[role_name].name => local.roles_definition[role_name].table_grants
      if local.roles_definition[role_name].enabled
    }
  )
  table_grants_on_existing = transpose(
    {
      for role_name, role in local.roles : local.roles[role_name].name => local.roles_definition[role_name].table_grants
      if local.roles_definition[role_name].enabled && local.roles_definition[role_name].add_grants_to_existing_objects
    }
  )

  dynamic_table_grants = {
    for role_name, role in local.roles : local.roles[role_name].name => local.roles_definition[role_name].dynamic_table_grants
    if local.roles_definition[role_name].enabled && length(local.roles_definition[role_name].dynamic_table_grants) > 0
  }
  dynamic_table_grants_on_existing = {
    for role_name, role in local.roles : local.roles[role_name].name => local.roles_definition[role_name].dynamic_table_grants
    if local.roles_definition[role_name].enabled && length(local.roles_definition[role_name].dynamic_table_grants) > 0 && local.roles_definition[role_name].add_grants_to_existing_objects
  }

  external_table_grants = transpose(
    {
      for role_name, role in local.roles : local.roles[role_name].name => local.roles_definition[role_name].external_table_grants
      if local.roles_definition[role_name].enabled
    }
  )
  external_table_grants_on_existing = transpose(
    {
      for role_name, role in local.roles : local.roles[role_name].name => local.roles_definition[role_name].external_table_grants
      if local.roles_definition[role_name].enabled && local.roles_definition[role_name].add_grants_to_existing_objects
    }
  )

  view_grants = transpose({ for role_name, role in local.roles : local.roles[role_name].name =>
    local.roles_definition[role_name].view_grants
    if local.roles_definition[role_name].enabled
  })
  view_grants_on_existing = transpose({ for role_name, role in local.roles : local.roles[role_name].name =>
    local.roles_definition[role_name].view_grants
    if local.roles_definition[role_name].enabled && local.roles_definition[role_name].add_grants_to_existing_objects
  })

  materialized_view_grants = transpose(
    {
      for role_name, role in local.roles : local.roles[role_name].name => local.roles_definition[role_name].materialized_view_grants
      if local.roles_definition[role_name].enabled
    }
  )
  materialized_view_grants_on_existing = transpose(
    {
      for role_name, role in local.roles : local.roles[role_name].name => local.roles_definition[role_name].materialized_view_grants
      if local.roles_definition[role_name].enabled && local.roles_definition[role_name].add_grants_to_existing_objects
    }
  )

  file_format_grants = transpose(
    {
      for role_name, role in local.roles : local.roles[role_name].name => local.roles_definition[role_name].file_format_grants
      if local.roles_definition[role_name].enabled
    }
  )
  file_format_grants_on_existing = transpose(
    {
      for role_name, role in local.roles : local.roles[role_name].name => local.roles_definition[role_name].file_format_grants
      if local.roles_definition[role_name].enabled && local.roles_definition[role_name].add_grants_to_existing_objects
    }
  )

  function_grants = transpose(
    {
      for role_name, role in local.roles : local.roles[role_name].name => local.roles_definition[role_name].function_grants
      if local.roles_definition[role_name].enabled
    }
  )
  function_grants_on_existing = transpose(
    {
      for role_name, role in local.roles : local.roles[role_name].name => local.roles_definition[role_name].function_grants
      if local.roles_definition[role_name].enabled && local.roles_definition[role_name].add_grants_to_existing_objects
    }
  )

  stage_grants = transpose(
    {
      for role_name, role in local.roles : local.roles[role_name].name => local.roles_definition[role_name].stage_grants
      if local.roles_definition[role_name].enabled
    }
  )
  stage_grants_on_existing = transpose(
    {
      for role_name, role in local.roles : local.roles[role_name].name => local.roles_definition[role_name].stage_grants
      if local.roles_definition[role_name].enabled && local.roles_definition[role_name].add_grants_to_existing_objects
    }
  )

  task_grants = transpose(
    {
      for role_name, role in local.roles : local.roles[role_name].name => local.roles_definition[role_name].task_grants
      if local.roles_definition[role_name].enabled
    }
  )
  task_grants_on_existing = transpose(
    {
      for role_name, role in local.roles : local.roles[role_name].name => local.roles_definition[role_name].task_grants
      if local.roles_definition[role_name].enabled && local.roles_definition[role_name].add_grants_to_existing_objects
    }
  )

  procedure_grants = transpose(
    {
      for role_name, role in local.roles : local.roles[role_name].name => local.roles_definition[role_name].procedure_grants
      if local.roles_definition[role_name].enabled
    }
  )
  procedure_grants_on_existing = transpose(
    {
      for role_name, role in local.roles : local.roles[role_name].name => local.roles_definition[role_name].procedure_grants
      if local.roles_definition[role_name].enabled && local.roles_definition[role_name].add_grants_to_existing_objects
    }
  )

  sequence_grants = transpose(
    {
      for role_name, role in local.roles : local.roles[role_name].name => local.roles_definition[role_name].sequence_grants
      if local.roles_definition[role_name].enabled
    }
  )
  sequence_grants_on_existing = transpose(
    {
      for role_name, role in local.roles : local.roles[role_name].name => local.roles_definition[role_name].sequence_grants
      if local.roles_definition[role_name].enabled && local.roles_definition[role_name].add_grants_to_existing_objects
    }
  )

  stream_grants = transpose(
    {
      for role_name, role in local.roles : local.roles[role_name].name => local.roles_definition[role_name].stream_grants
      if local.roles_definition[role_name].enabled
    }
  )
  stream_grants_on_existing = transpose(
    {
      for role_name, role in local.roles : local.roles[role_name].name => local.roles_definition[role_name].stream_grants
      if local.roles_definition[role_name].enabled && local.roles_definition[role_name].add_grants_to_existing_objects
    }
  )
}

module "roles_deep_merge" {
  source  = "Invicton-Labs/deepmerge/null"
  version = "0.1.5"

  maps = [local.default_roles_definition, local.provided_roles]
}
