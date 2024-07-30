locals {
  # Get a name from the descriptor. If not available, use default naming convention.
  # Trim and replace function are used to avoid bare delimiters on both ends of the name and situation of adjacent delimiters.
  name_from_descriptor = module.schema_label.enabled ? trim(replace(
    lookup(module.schema_label.descriptors, var.descriptor_name, module.schema_label.id), "/${module.schema_label.delimiter}${module.schema_label.delimiter}+/", module.schema_label.delimiter
  ), module.schema_label.delimiter) : null

  schema   = coalesce(one(snowflake_schema.this[*].name), var.name)
  database = var.database

  # This needs to be the same as an object in roles variable
  role_template = {
    enabled                   = true
    role_ownership_grant      = "SYSADMIN"
    granted_to_roles          = []
    granted_database_roles    = []
    granted_to_database_roles = []
    schema_grants             = []
    database_grants           = []
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

  default_roles_definition = var.create_default_roles ? {
    readonly = {
      schema_grants = [{
        privileges                 = ["USAGE"]
        all_schemas_in_database    = true
        future_schemas_in_database = true
      }]
      schema_objects_grants = {
        "TABLE" = [{
          privileges = ["SELECT"]
          on_all     = true
          on_future  = true
        }]
        "DYNAMIC TABLE" = [{
          privileges = ["SELECT"]
          on_all     = true
          on_future  = true
        }]
        "EXTERNAL TABLE" = [{
          privileges = ["SELECT", "REFERENCES"]
          on_all     = true
          on_future  = true
        }]
        "VIEW" = [{
          privileges = ["SELECT", "REFERENCES"]
          on_all     = true
          on_future  = true
        }]
        "MATERIALIZED VIEW" = [{
          privileges = ["SELECT", "REFERENCES"]
          on_all     = true
          on_future  = true
        }]
        "FILE FORMAT" = [{
          privileges = ["USAGE"]
          on_all     = true
          on_future  = true
        }]
        "FUNCTION" = [{
          privileges = ["USAGE"]
          on_all     = true
          on_future  = true
        }]
        "STAGE" = [{
          privileges = ["USAGE"]
          on_all     = true
          on_future  = true
        }]
        "TASK" = [{
          privileges = ["MONITOR"]
          on_all     = true
          on_future  = true
        }]
      }
    }
    readwrite = {
      schema_grants = [{
        privileges                 = ["USAGE"]
        all_schemas_in_database    = true
        future_schemas_in_database = true
      }]
      schema_objects_grants = {
        "TABLE" = [{
          privileges = ["SELECT", "INSERT", "UPDATE", "DELETE", "TRUNCATE", "REFERENCES", "REBUILD"]
          on_all     = true
          on_future  = true
        }]
        "DYNAMIC TABLE" = [{
          privileges = ["SELECT"]
          on_all     = true
          on_future  = true
        }]
        "EXTERNAL TABLE" = [{
          privileges = ["SELECT", "REFERENCES"]
          on_all     = true
          on_future  = true
        }]
        "VIEW" = [{
          privileges = ["SELECT", "REFERENCES"]
          on_all     = true
          on_future  = true
        }]
        "MATERIALIZED VIEW" = [{
          privileges = ["SELECT", "REFERENCES"]
          on_all     = true
          on_future  = true
        }]
        "FILE FORMAT" = [{
          privileges = ["USAGE"]
          on_all     = true
          on_future  = true
        }]
        "FUNCTION" = [{
          privileges = ["USAGE"]
          on_all     = true
          on_future  = true
        }]
        "STAGE" = [{
          privileges = ["USAGE", "READ", "WRITE"]
          on_all     = true
          on_future  = true
        }]
        "TASK" = [{
          privileges = ["MONITOR", "OPERATE"]
          on_all     = true
          on_future  = true
        }]
        "PROCEDURE" = [{
          privileges = ["USAGE"]
          on_all     = true
          on_future  = true
        }]
      }
    }
    admin = {
      schema_grants = [{
        privileges                 = ["ALL PRIVILEGES"]
        all_schemas_in_database    = true
        future_schemas_in_database = true
      }]
      schema_objects_grants = {
        "TABLE" = [{
          privileges = ["ALL PRIVILEGES"]
          on_all     = true
          on_future  = true
        }]
        "DYNAMIC TABLE" = [{
          privileges = ["ALL PRIVILEGES"]
          on_all     = true
          on_future  = true
        }]
        "EXTERNAL TABLE" = [{
          privileges = ["ALL PRIVILEGES"]
          on_all     = true
          on_future  = true
        }]
        "VIEW" = [{
          privileges = ["ALL PRIVILEGES"]
          on_all     = true
          on_future  = true
        }]
        "MATERIALIZED VIEW" = [{
          privileges = ["ALL PRIVILEGES"]
          on_all     = true
          on_future  = true
        }]
        "FILE FORMAT" = [{
          privileges = ["ALL PRIVILEGES"]
          on_all     = true
          on_future  = true
        }]
        "FUNCTION" = [{
          privileges = ["ALL PRIVILEGES"]
          on_all     = true
          on_future  = true
        }]
        "STAGE" = [{
          privileges = ["ALL PRIVILEGES"]
          on_all     = true
          on_future  = true
        }]
        "TASK" = [{
          privileges = ["ALL PRIVILEGES"]
          on_all     = true
          on_future  = true
        }]
        "PROCEDURE" = [{
          privileges = ["ALL PRIVILEGES"]
          on_all     = true
          on_future  = true
        }]
      }
    }
    transformer = {
      schema_grants = [{
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
        all_schemas_in_database    = true
        future_schemas_in_database = true
      }]
      schema_objects_grants = {
        "TABLE" = [{
          privileges = ["SELECT", "INSERT", "UPDATE", "DELETE", "TRUNCATE", "REFERENCES", "REBUILD"]
          on_all     = true
          on_future  = true
        }]
        "DYNAMIC TABLE" = [{
          privileges = ["ALL PRIVILEGES"]
          on_all     = true
          on_future  = true
        }]
        "EXTERNAL TABLE" = [{
          privileges = ["SELECT", "REFERENCES"]
          on_all     = true
          on_future  = true
        }]
        "VIEW" = [{
          privileges = ["SELECT", "REFERENCES"]
          on_all     = true
          on_future  = true
        }]
        "MATERIALIZED VIEW" = [{
          privileges = ["SELECT", "REFERENCES"]
          on_all     = true
          on_future  = true
        }]
        "FILE FORMAT" = [{
          privileges = ["USAGE"]
          on_all     = true
          on_future  = true
        }]
        "FUNCTION" = [{
          privileges = ["USAGE"]
          on_all     = true
          on_future  = true
        }]
        "STAGE" = [{
          privileges = ["USAGE", "READ", "WRITE"]
          on_all     = true
          on_future  = true
        }]
        "TASK" = [{
          privileges = ["MONITOR", "OPERATE"]
          on_all     = true
          on_future  = true
        }]
        "PROCEDURE" = [{
          privileges = ["USAGE"]
          on_all     = true
          on_future  = true
        }]
      }
    }
  } : {}

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

  roles = {
    for role_name, role in local.roles_definition : role_name => role
    if role_name != null && role.enabled
  }
}

module "roles_deep_merge" {
  source  = "Invicton-Labs/deepmerge/null"
  version = "0.1.5"

  maps = [local.default_roles_definition, local.provided_roles]
}
