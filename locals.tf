locals {
  # Get a name from the descriptor. If not available, use default naming convention.
  # Trim and replace function are used to avoid bare delimiters on both ends of the name and situation of adjacent delimiters.
  name_from_descriptor = module.schema_label.enabled ? trim(replace(
    lookup(module.schema_label.descriptors, var.descriptor_name, module.schema_label.id), "/${module.schema_label.delimiter}${module.schema_label.delimiter}+/", module.schema_label.delimiter
  ), module.schema_label.delimiter) : null

  default_roles = {
    readonly = {
      schema_grants = {
        privileges = ["USAGE"]
      }
      table_grants = {
        _ = {
          privileges = ["SELECT"]
        }
      }
      external_table_grants = {
        _ = {
          privileges = ["SELECT", "REFERENCES"]
        }
      }
      view_grants = {
        _ = {
          privileges = ["SELECT", "REFERENCES"]
        }
      }
      materialized_view_grants = {
        _ = {
          privileges = ["SELECT", "REFERENCES"]
        }
      }
      file_format_grants = {
        _ = {
          privileges = ["USAGE"]
        }
      }
      function_grants = {
        _ = {
          privileges = ["USAGE"]
        }
      }
      stage_grants = {
        _ = {
          privileges = ["USAGE"]
        }
      }
      task_grants = {
        _ = {
          privileges = ["MONITOR"]
        }
      }
    }
    read_classified = {}
    readwrite = {
      table_grants = {
        _ = {
          privileges = ["INSERT", "UPDATE", "DELETE", "TRUNCATE", "REFERENCES", "REBUILD"]
          on_future  = true
      } }
      stage_grants = {
        _ = {
          privileges = ["READ", "WRITE"]
        }
      }
      procedure_grants = {
        _ = {
          privileges = ["USAGE"]
        }
      }
      task_grants = {
        _ = {
          privileges = ["OPERATE"]
        }
      }
    }
    modify = {
      table_grants = {
        _ = {
          privileges = ["OWNERSHIP"]
        }
      }
      external_table_grants = {
        _ = {
          privileges = ["OWNERSHIP"]
        }
      }
      view_grants = {
        _ = {
          privileges = ["OWNERSHIP"]
        }
      }
      materialized_view_grants = {
        _ = {
          privileges = ["OWNERSHIP"]
        }
      }
      file_format_grants = {
        _ = {
          privileges = ["OWNERSHIP"]
        }
      }
      function_grants = {
        _ = {
          privileges = ["OWNERSHIP"]
        }
      }
      stage_grants = {
        _ = {
          privileges = ["OWNERSHIP"]
        }
      }
      task_grants = {
        _ = {
          privileges = ["OWNERSHIP"]
        }
      }
      procedure_grants = {
        _ = {
          privileges = ["OWNERSHIP"]
        }
      }
      sequence_grants = {
        _ = {
          privileges = ["OWNERSHIP"]
        }
      }
      stream_grants = {
        _ = {
          privileges = ["OWNERSHIP"]
        }
      }
    }
    admin = {
      schema_grants = {
        privileges = ["MONITOR", "CREATE TEMPORARY TABLE", "CREATE TAG", "CREATE PIPE", "CREATE PROCEDURE", "CREATE MATERIALIZED VIEW", "CREATE ROW ACCESS POLICY", "USAGE", "CREATE TABLE", "CREATE FILE FORMAT", "CREATE STAGE", "CREATE TASK", "CREATE FUNCTION", "CREATE EXTERNAL TABLE", "ADD SEARCH OPTIMIZATION", "MODIFY", "OWNERSHIP", "CREATE SEQUENCE", "CREATE MASKING POLICY", "CREATE VIEW", "CREATE STREAM"]
      }
    }
  }

  provided_roles = { for role_name, role in var.roles : role_name => {
    for k, v in role : k => v
    if v != null
  } }
  roles = module.roles_deep_merge.merged

  custom_roles = {
    for role_name, role in local.roles : role_name => role
    if !contains(keys(local.default_roles), role_name)
  }

  role_modules = merge(
    module.snowflake_readonly_role.name != null ? { readonly = module.snowflake_readonly_role } : {},
    module.snowflake_readwrite_role.name != null ? { readwrite = module.snowflake_readwrite_role } : {},
    module.snowflake_read_classified_role.name != null ? { read_classified = module.snowflake_read_classified_role } : {},
    module.snowflake_modify_role.name != null ? { modify = module.snowflake_modify_role } : {},
    module.snowflake_admin_role.name != null ? { admin = module.snowflake_admin_role } : {},
    module.snowflake_custom_role
  )
}

module "roles_deep_merge" {
  source  = "Invicton-Labs/deepmerge/null"
  version = "0.1.5"

  maps = [local.default_roles, var.roles]
}
