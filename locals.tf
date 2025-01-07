locals {
  context_template = lookup(var.context_templates, var.name_scheme.context_template_name, null)
  schema_name      = coalesce(one(snowflake_schema.this[*].name), var.name)

  default_role_naming_scheme = {
    properties            = ["schema", "name"]
    context_template_name = "snowflake-schema-database-role"
    extra_values = {
      database = var.database
      schema   = var.name
    }
    uppercase = var.name_scheme.uppercase
  }

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
        schema_name = local.schema_name
      }]
      schema_objects_grants = {
        "TABLE" = [{
          schema_name = local.schema_name
          privileges  = ["SELECT"]
          on_all      = true
          on_future   = true
        }]
        "DYNAMIC TABLE" = [{
          schema_name = local.schema_name
          privileges  = ["SELECT"]
          on_all      = true
          on_future   = true
        }]
        "EXTERNAL TABLE" = [{
          schema_name = local.schema_name
          privileges  = ["SELECT", "REFERENCES"]
          on_all      = true
          on_future   = true
        }]
        "VIEW" = [{
          schema_name = local.schema_name
          privileges  = ["SELECT", "REFERENCES"]
          on_all      = true
          on_future   = true
        }]
        "MATERIALIZED VIEW" = [{
          schema_name = local.schema_name
          privileges  = ["SELECT", "REFERENCES"]
          on_all      = true
          on_future   = true
        }]
        "FILE FORMAT" = [{
          schema_name = local.schema_name
          privileges  = ["USAGE"]
          on_all      = true
          on_future   = true
        }]
        "FUNCTION" = [{
          schema_name = local.schema_name
          privileges  = ["USAGE"]
          on_all      = true
          on_future   = true
        }]
        "STAGE" = [{
          schema_name = local.schema_name
          privileges  = ["USAGE"]
          on_all      = true
          on_future   = true
        }]
        "TASK" = [{
          schema_name = local.schema_name
          privileges  = ["MONITOR"]
          on_all      = true
          on_future   = true
        }]
      }
    }
    readwrite = {
      schema_grants = [{
        privileges  = ["USAGE"]
        schema_name = local.schema_name
      }]
      schema_objects_grants = {
        "TABLE" = [{
          schema_name = local.schema_name
          privileges  = ["SELECT", "INSERT", "UPDATE", "DELETE", "TRUNCATE", "REFERENCES", "REBUILD"]
          on_all      = true
          on_future   = true
        }]
        "DYNAMIC TABLE" = [{
          schema_name = local.schema_name
          privileges  = ["SELECT"]
          on_all      = true
          on_future   = true
        }]
        "EXTERNAL TABLE" = [{
          schema_name = local.schema_name
          privileges  = ["SELECT", "REFERENCES"]
          on_all      = true
          on_future   = true
        }]
        "VIEW" = [{
          schema_name = local.schema_name
          privileges  = ["SELECT", "REFERENCES"]
          on_all      = true
          on_future   = true
        }]
        "MATERIALIZED VIEW" = [{
          schema_name = local.schema_name
          privileges  = ["SELECT", "REFERENCES"]
          on_all      = true
          on_future   = true
        }]
        "FILE FORMAT" = [{
          schema_name = local.schema_name
          privileges  = ["USAGE"]
          on_all      = true
          on_future   = true
        }]
        "FUNCTION" = [{
          schema_name = local.schema_name
          privileges  = ["USAGE"]
          on_all      = true
          on_future   = true
        }]
        "STAGE" = [{
          schema_name = local.schema_name
          privileges  = ["USAGE", "READ", "WRITE"]
          on_all      = true
          on_future   = true
        }]
        "TASK" = [{
          schema_name = local.schema_name
          privileges  = ["MONITOR", "OPERATE"]
          on_all      = true
          on_future   = true
        }]
        "PROCEDURE" = [{
          schema_name = local.schema_name
          privileges  = ["USAGE"]
          on_all      = true
          on_future   = true
        }]
      }
    }
    admin = {
      schema_grants = [{
        privileges  = ["ALL PRIVILEGES"]
        schema_name = local.schema_name
      }]
      schema_objects_grants = {
        "TABLE" = [{
          privileges  = ["ALL PRIVILEGES"]
          on_all      = true
          on_future   = true
          schema_name = local.schema_name
        }]
        "DYNAMIC TABLE" = [{
          privileges  = ["ALL PRIVILEGES"]
          on_all      = true
          on_future   = true
          schema_name = local.schema_name
        }]
        "EXTERNAL TABLE" = [{
          privileges  = ["ALL PRIVILEGES"]
          on_all      = true
          on_future   = true
          schema_name = local.schema_name
        }]
        "VIEW" = [{
          privileges  = ["ALL PRIVILEGES"]
          on_all      = true
          on_future   = true
          schema_name = local.schema_name
        }]
        "MATERIALIZED VIEW" = [{
          privileges  = ["ALL PRIVILEGES"]
          on_all      = true
          on_future   = true
          schema_name = local.schema_name
        }]
        "FILE FORMAT" = [{
          privileges  = ["ALL PRIVILEGES"]
          on_all      = true
          on_future   = true
          schema_name = local.schema_name
        }]
        "FUNCTION" = [{
          privileges  = ["ALL PRIVILEGES"]
          on_all      = true
          on_future   = true
          schema_name = local.schema_name
        }]
        "STAGE" = [{
          privileges  = ["ALL PRIVILEGES"]
          on_all      = true
          on_future   = true
          schema_name = local.schema_name
        }]
        "TASK" = [{
          privileges  = ["ALL PRIVILEGES"]
          on_all      = true
          on_future   = true
          schema_name = local.schema_name
        }]
        "PROCEDURE" = [{
          privileges  = ["ALL PRIVILEGES"]
          on_all      = true
          on_future   = true
          schema_name = local.schema_name
        }]
      }
    }
    transformer = {
      schema_grants = [{
        schema_name = local.schema_name
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
          schema_name = local.schema_name
          privileges  = ["SELECT", "INSERT", "UPDATE", "DELETE", "TRUNCATE", "REFERENCES", "REBUILD"]
          on_all      = true
          on_future   = true
        }]
        "DYNAMIC TABLE" = [{
          schema_name = local.schema_name
          privileges  = ["ALL PRIVILEGES"]
          on_all      = true
          on_future   = true
        }]
        "EXTERNAL TABLE" = [{
          schema_name = local.schema_name
          privileges  = ["SELECT", "REFERENCES"]
          on_all      = true
          on_future   = true
        }]
        "VIEW" = [{
          schema_name = local.schema_name
          privileges  = ["SELECT", "REFERENCES"]
          on_all      = true
          on_future   = true
        }]
        "MATERIALIZED VIEW" = [{
          schema_name = local.schema_name
          privileges  = ["SELECT", "REFERENCES"]
          on_all      = true
          on_future   = true
        }]
        "FILE FORMAT" = [{
          schema_name = local.schema_name
          privileges  = ["USAGE"]
          on_all      = true
          on_future   = true
        }]
        "FUNCTION" = [{
          schema_name = local.schema_name
          privileges  = ["USAGE"]
          on_all      = true
          on_future   = true
        }]
        "STAGE" = [{
          schema_name = local.schema_name
          privileges  = ["USAGE", "READ", "WRITE"]
          on_all      = true
          on_future   = true
        }]
        "TASK" = [{
          schema_name = local.schema_name
          privileges  = ["MONITOR", "OPERATE"]
          on_all      = true
          on_future   = true
        }]
        "PROCEDURE" = [{
          schema_name = local.schema_name
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
          for object in v : merge(object, { schema_name = local.schema_name })
        ]
        if v != null && k == "schema_grants"
      },
      {
        for k, v in role : k => {
          for object, config in v : object => [
            for grant in config : merge(
              grant,
              {
                schema_name = local.schema_name
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
    if contains(keys(local.default_roles_definition), role_name) && var.create_default_roles
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
    if role_name != null
  }
}

module "roles_deep_merge" {
  source  = "Invicton-Labs/deepmerge/null"
  version = "0.1.5"

  maps = [local.default_roles_definition, local.provided_roles]
}
