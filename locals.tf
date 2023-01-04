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
      schema_grants = {
        privileges = ["USAGE"]
      }
      table_grants = {
        (local.on_future_grant_key) = {
          privileges = ["SELECT"]
        }
      }
      external_table_grants = {
        (local.on_future_grant_key) = {
          privileges = ["SELECT", "REFERENCES"]
        }
      }
      view_grants = {
        (local.on_future_grant_key) = {
          privileges = ["SELECT", "REFERENCES"]
        }
      }
      materialized_view_grants = {
        (local.on_future_grant_key) = {
          privileges = ["SELECT", "REFERENCES"]
        }
      }
      file_format_grants = {
        (local.on_future_grant_key) = {
          privileges = ["USAGE"]
        }
      }
      function_grants = {
        (local.on_future_grant_key) = {
          privileges = ["USAGE"]
        }
      }
      stage_grants = {
        (local.on_future_grant_key) = {
          privileges = ["USAGE"]
        }
      }
      task_grants = {
        (local.on_future_grant_key) = {
          privileges = ["MONITOR"]
        }
      }
    }
    read_classified = {}
    readwrite = {
      schema_grants = {
        privileges = ["USAGE"]
      }
      table_grants = {
        (local.on_future_grant_key) = {
          privileges = ["SELECT", "INSERT", "UPDATE", "DELETE", "TRUNCATE", "REFERENCES", "REBUILD"]
          on_future  = true
      } }
      external_table_grants = {
        (local.on_future_grant_key) = {
          privileges = ["SELECT", "REFERENCES"]
        }
      }
      view_grants = {
        (local.on_future_grant_key) = {
          privileges = ["SELECT", "REFERENCES"]
        }
      }
      materialized_view_grants = {
        (local.on_future_grant_key) = {
          privileges = ["SELECT", "REFERENCES"]
        }
      }
      file_format_grants = {
        (local.on_future_grant_key) = {
          privileges = ["USAGE"]
        }
      }
      function_grants = {
        (local.on_future_grant_key) = {
          privileges = ["USAGE"]
        }
      }
      stage_grants = {
        (local.on_future_grant_key) = {
          privileges = ["USAGE", "READ", "WRITE"]
        }
      }
      task_grants = {
        (local.on_future_grant_key) = {
          privileges = ["MONITOR", "OPERATE"]
        }
      }
      procedure_grants = {
        (local.on_future_grant_key) = {
          privileges = ["USAGE"]
        }
      }
    }
    modify = {
      schema_grants = {
        privileges = ["USAGE"]
      }
      table_grants = {
        (local.on_future_grant_key) = {
          privileges = ["SELECT", "INSERT", "UPDATE", "DELETE", "TRUNCATE", "REFERENCES", "REBUILD", "OWNERSHIP"]
          on_future  = true
      } }
      external_table_grants = {
        (local.on_future_grant_key) = {
          privileges = ["SELECT", "REFERENCES", "OWNERSHIP"]
        }
      }
      view_grants = {
        (local.on_future_grant_key) = {
          privileges = ["SELECT", "REFERENCES", "OWNERSHIP"]
        }
      }
      materialized_view_grants = {
        (local.on_future_grant_key) = {
          privileges = ["SELECT", "REFERENCES", "OWNERSHIP"]
        }
      }
      file_format_grants = {
        (local.on_future_grant_key) = {
          privileges = ["USAGE", "OWNERSHIP", "OWNERSHIP"]
        }
      }
      function_grants = {
        (local.on_future_grant_key) = {
          privileges = ["USAGE", "OWNERSHIP"]
        }
      }
      stage_grants = {
        (local.on_future_grant_key) = {
          privileges = ["USAGE", "READ", "WRITE", "OWNERSHIP"]
        }
      }
      task_grants = {
        (local.on_future_grant_key) = {
          privileges = ["MONITOR", "OPERATE", "OWNERSHIP"]
        }
      }
      procedure_grants = {
        (local.on_future_grant_key) = {
          privileges = ["USAGE", "OWNERSHIP"]
        }
      }
      sequence_grants = {
        (local.on_future_grant_key) = {
          privileges = ["OWNERSHIP"]
        }
      }
      stream_grants = {
        (local.on_future_grant_key) = {
          privileges = ["OWNERSHIP"]
        }
      }
    }
    admin = {
      schema_grants = {
        privileges = ["MONITOR", "CREATE TEMPORARY TABLE", "CREATE TAG", "CREATE PIPE", "CREATE PROCEDURE", "CREATE MATERIALIZED VIEW", "CREATE ROW ACCESS POLICY", "USAGE", "CREATE TABLE", "CREATE FILE FORMAT", "CREATE STAGE", "CREATE TASK", "CREATE FUNCTION", "CREATE EXTERNAL TABLE", "ADD SEARCH OPTIMIZATION", "MODIFY", "OWNERSHIP", "CREATE SEQUENCE", "CREATE MASKING POLICY", "CREATE VIEW", "CREATE STREAM"]
      }
      table_grants = {
        (local.on_future_grant_key) = {
          privileges = ["SELECT", "INSERT", "UPDATE", "DELETE", "TRUNCATE", "REFERENCES", "REBUILD", "OWNERSHIP"]
          on_future  = true
      } }
      external_table_grants = {
        (local.on_future_grant_key) = {
          privileges = ["SELECT", "REFERENCES", "OWNERSHIP"]
        }
      }
      view_grants = {
        (local.on_future_grant_key) = {
          privileges = ["SELECT", "REFERENCES", "OWNERSHIP"]
        }
      }
      materialized_view_grants = {
        (local.on_future_grant_key) = {
          privileges = ["SELECT", "REFERENCES", "OWNERSHIP"]
        }
      }
      file_format_grants = {
        (local.on_future_grant_key) = {
          privileges = ["USAGE", "OWNERSHIP", "OWNERSHIP"]
        }
      }
      function_grants = {
        (local.on_future_grant_key) = {
          privileges = ["USAGE", "OWNERSHIP"]
        }
      }
      stage_grants = {
        (local.on_future_grant_key) = {
          privileges = ["USAGE", "READ", "WRITE", "OWNERSHIP"]
        }
      }
      task_grants = {
        (local.on_future_grant_key) = {
          privileges = ["MONITOR", "OPERATE", "OWNERSHIP"]
        }
      }
      procedure_grants = {
        (local.on_future_grant_key) = {
          privileges = ["USAGE", "OWNERSHIP"]
        }
      }
      sequence_grants = {
        (local.on_future_grant_key) = {
          privileges = ["OWNERSHIP"]
        }
      }
      stream_grants = {
        (local.on_future_grant_key) = {
          privileges = ["OWNERSHIP"]
        }
      }
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
