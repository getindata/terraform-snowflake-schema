locals {
  # Get a name from the descriptor. If not available, use default naming convention.
  # Trim and replace function are used to avoid bare delimiters on both ends of the name and situation of adjacent delimiters.
  name_from_descriptor = module.schema_label.enabled ? trim(replace(
    lookup(module.schema_label.descriptors, var.descriptor_name, module.schema_label.id), "/${module.schema_label.delimiter}${module.schema_label.delimiter}+/", module.schema_label.delimiter
  ), module.schema_label.delimiter) : null

  create_default_roles = module.this.enabled && var.create_default_roles

  schema   = module.this.enabled ? coalesce(one(snowflake_schema.this[*].name), var.name) : null
  database = var.database

  # This needs to be the same as an object in roles variable
  role_template = {
    enabled                   = true
    role_ownership_grant      = "SYSADMIN"
    granted_to_roles          = []
    granted_database_roles    = []
    granted_to_database_roles = []
    schema_grants             = []
    schema_objects_grants = {
      "TABLE"             = []
      "DYNAMIC TABLE"     = []
      "EXTERNAL TABLE"    = []
      "VIEW"              = []
      "MATERIALIZED VIEW" = []
      "FILE FORMAT"       = []
      "FUNCTION"          = []
      "STAGE"             = []
      "TASK"              = []
      "PROCEDURE"         = []
      "SEQUENCE"          = []
      "STREAM"            = []
    }
  }

  default_roles_definition = {
    readonly = {
      schema_grants = [{
        privileges  = ["USAGE"]
        schema_name = local.name_from_descriptor
      }]
      schema_objects_grants = {
        "TABLE" = [{
          schema_name = local.name_from_descriptor
          privileges  = ["SELECT"]
          on_all      = true
          on_future   = true
        }]
        "DYNAMIC TABLE" = [{
          schema_name = local.name_from_descriptor
          privileges  = ["SELECT"]
          on_all      = true
          on_future   = true
        }]
        "EXTERNAL TABLE" = [{
          schema_name = local.name_from_descriptor
          privileges  = ["SELECT", "REFERENCES"]
          on_all      = true
          on_future   = true
        }]
        "VIEW" = [{
          schema_name = local.name_from_descriptor
          privileges  = ["SELECT", "REFERENCES"]
          on_all      = true
          on_future   = true
        }]
        "MATERIALIZED VIEW" = [{
          schema_name = local.name_from_descriptor
          privileges  = ["SELECT", "REFERENCES"]
          on_all      = true
          on_future   = true
        }]
        "FILE FORMAT" = [{
          schema_name = local.name_from_descriptor
          privileges  = ["USAGE"]
          on_all      = true
          on_future   = true
        }]
        "FUNCTION" = [{
          schema_name = local.name_from_descriptor
          privileges  = ["USAGE"]
          on_all      = true
          on_future   = true
        }]
        "STAGE" = [{
          schema_name = local.name_from_descriptor
          privileges  = ["USAGE"]
          on_all      = true
          on_future   = true
        }]
        "TASK" = [{
          schema_name = local.name_from_descriptor
          privileges  = ["MONITOR"]
          on_all      = true
          on_future   = true
        }]
      }
    }
    readwrite = {
      schema_grants = [{
        privileges  = ["USAGE"]
        schema_name = local.name_from_descriptor
      }]
      schema_objects_grants = {
        "TABLE" = [{
          schema_name = local.name_from_descriptor
          privileges  = ["SELECT", "INSERT", "UPDATE", "DELETE", "TRUNCATE", "REFERENCES", "REBUILD"]
          on_all      = true
          on_future   = true
        }]
        "DYNAMIC TABLE" = [{
          schema_name = local.name_from_descriptor
          privileges  = ["SELECT"]
          on_all      = true
          on_future   = true
        }]
        "EXTERNAL TABLE" = [{
          schema_name = local.name_from_descriptor
          privileges  = ["SELECT", "REFERENCES"]
          on_all      = true
          on_future   = true
        }]
        "VIEW" = [{
          schema_name = local.name_from_descriptor
          privileges  = ["SELECT", "REFERENCES"]
          on_all      = true
          on_future   = true
        }]
        "MATERIALIZED VIEW" = [{
          schema_name = local.name_from_descriptor
          privileges  = ["SELECT", "REFERENCES"]
          on_all      = true
          on_future   = true
        }]
        "FILE FORMAT" = [{
          schema_name = local.name_from_descriptor
          privileges  = ["USAGE"]
          on_all      = true
          on_future   = true
        }]
        "FUNCTION" = [{
          schema_name = local.name_from_descriptor
          privileges  = ["USAGE"]
          on_all      = true
          on_future   = true
        }]
        "STAGE" = [{
          schema_name = local.name_from_descriptor
          privileges  = ["USAGE", "READ", "WRITE"]
          on_all      = true
          on_future   = true
        }]
        "TASK" = [{
          schema_name = local.name_from_descriptor
          privileges  = ["MONITOR", "OPERATE"]
          on_all      = true
          on_future   = true
        }]
        "PROCEDURE" = [{
          schema_name = local.name_from_descriptor
          privileges  = ["USAGE"]
          on_all      = true
          on_future   = true
        }]
      }
    }
    admin = {
      schema_grants = [{
        privileges  = ["ALL PRIVILEGES"]
        schema_name = local.name_from_descriptor
      }]
      schema_objects_grants = {
        "TABLE" = [{
          privileges  = ["ALL PRIVILEGES"]
          on_all      = true
          on_future   = true
          schema_name = local.name_from_descriptor
        }]
        "DYNAMIC TABLE" = [{
          privileges  = ["ALL PRIVILEGES"]
          on_all      = true
          on_future   = true
          schema_name = local.name_from_descriptor
        }]
        "EXTERNAL TABLE" = [{
          privileges  = ["ALL PRIVILEGES"]
          on_all      = true
          on_future   = true
          schema_name = local.name_from_descriptor
        }]
        "VIEW" = [{
          privileges  = ["ALL PRIVILEGES"]
          on_all      = true
          on_future   = true
          schema_name = local.name_from_descriptor
        }]
        "MATERIALIZED VIEW" = [{
          privileges  = ["ALL PRIVILEGES"]
          on_all      = true
          on_future   = true
          schema_name = local.name_from_descriptor
        }]
        "FILE FORMAT" = [{
          privileges  = ["ALL PRIVILEGES"]
          on_all      = true
          on_future   = true
          schema_name = local.name_from_descriptor
        }]
        "FUNCTION" = [{
          privileges  = ["ALL PRIVILEGES"]
          on_all      = true
          on_future   = true
          schema_name = local.name_from_descriptor
        }]
        "STAGE" = [{
          privileges  = ["ALL PRIVILEGES"]
          on_all      = true
          on_future   = true
          schema_name = local.name_from_descriptor
        }]
        "TASK" = [{
          privileges  = ["ALL PRIVILEGES"]
          on_all      = true
          on_future   = true
          schema_name = local.name_from_descriptor
        }]
        "PROCEDURE" = [{
          privileges  = ["ALL PRIVILEGES"]
          on_all      = true
          on_future   = true
          schema_name = local.name_from_descriptor
        }]
      }
    }
    transformer = {
      schema_grants = [{
        schema_name = local.name_from_descriptor
        privileges = [
          "CREATE TEMPORARY TABLE",
          "CREATE TAG",
          "CREATE PIPE",
          "CREATE PROCEDURE",
          "CREATE MATERIALIZED VIEW",
          "USAGE",
          "CREATE TABLE",
          "CREATE FILE FORMAT",
          "CREATE STAGE",
          "CREATE TASK",
          "CREATE FUNCTION",
          "CREATE EXTERNAL TABLE",
          "CREATE SEQUENCE",
          "CREATE VIEW",
          "CREATE STREAM"
        ]
      }]
      schema_objects_grants = {
        "TABLE" = [{
          schema_name = local.name_from_descriptor
          privileges  = ["SELECT", "INSERT", "UPDATE", "DELETE", "TRUNCATE", "REFERENCES", "REBUILD"]
          on_all      = true
          on_future   = true
        }]
        "DYNAMIC TABLE" = [{
          schema_name = local.name_from_descriptor
          privileges  = ["ALL PRIVILEGES"]
          on_all      = true
          on_future   = true
        }]
        "EXTERNAL TABLE" = [{
          schema_name = local.name_from_descriptor
          privileges  = ["SELECT", "REFERENCES"]
          on_all      = true
          on_future   = true
        }]
        "VIEW" = [{
          schema_name = local.name_from_descriptor
          privileges  = ["SELECT", "REFERENCES"]
          on_all      = true
          on_future   = true
        }]
        "MATERIALIZED VIEW" = [{
          schema_name = local.name_from_descriptor
          privileges  = ["SELECT", "REFERENCES"]
          on_all      = true
          on_future   = true
        }]
        "FILE FORMAT" = [{
          schema_name = local.name_from_descriptor
          privileges  = ["USAGE"]
          on_all      = true
          on_future   = true
        }]
        "FUNCTION" = [{
          schema_name = local.name_from_descriptor
          privileges  = ["USAGE"]
          on_all      = true
          on_future   = true
        }]
        "STAGE" = [{
          schema_name = local.name_from_descriptor
          privileges  = ["USAGE", "READ", "WRITE"]
          on_all      = true
          on_future   = true
        }]
        "TASK" = [{
          schema_name = local.name_from_descriptor
          privileges  = ["MONITOR", "OPERATE"]
          on_all      = true
          on_future   = true
        }]
        "PROCEDURE" = [{
          schema_name = local.name_from_descriptor
          privileges  = ["USAGE"]
          on_all      = true
          on_future   = true
        }]
      }
    }
  }

  # Cleanup null values and add current schema_name to the objects
  provided_roles = {
    for role_name, role in var.roles : role_name => merge(
      {
        for k, v in role : k => v
        if v != null && k != "schema_objects_grants" && k != "schema_grants"
      },
      {
        for k, v in role : k => [
          for object in v : merge(object, { schema_name = local.name_from_descriptor })
        ]
        if v != null && k == "schema_grants"
      },
      {
        for k, v in role : k => {
          for object, config in v : object => [
            for grant in config : merge(
              grant,
              {
                schema_name = local.name_from_descriptor
              }
            )
          ]
        }
        if v != null && k == "schema_objects_grants"
      }
    )
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
}

module "roles_deep_merge" {
  source  = "Invicton-Labs/deepmerge/null"
  version = "0.1.5"

  maps = [local.default_roles_definition, local.provided_roles]
}
