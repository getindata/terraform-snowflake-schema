locals {
  # Get a name from the descriptor. If not available, use default naming convention.
  # Trim and replace function are used to avoid bare delimiters on both ends of the name and situation of adjacent delimiters.
  name_from_descriptor = module.schema_label.enabled ? trim(replace(
    lookup(module.schema_label.descriptors, var.descriptor_name, module.schema_label.id), "/${module.schema_label.delimiter}${module.schema_label.delimiter}+/", module.schema_label.delimiter
  ), module.schema_label.delimiter) : null

  create_default_roles = module.this.enabled && var.create_default_roles
  on_future_grant_key  = "_"

  default_roles = {
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
      table_grants = {
        (local.on_future_grant_key) = {
          privileges = ["INSERT", "UPDATE", "DELETE", "TRUNCATE", "REFERENCES", "REBUILD"]
          on_future  = true
      } }
      stage_grants = {
        (local.on_future_grant_key) = {
          privileges = ["READ", "WRITE"]
        }
      }
      procedure_grants = {
        (local.on_future_grant_key) = {
          privileges = ["USAGE"]
        }
      }
      task_grants = {
        (local.on_future_grant_key) = {
          privileges = ["OPERATE"]
        }
      }
    }
    modify = {
      table_grants = {
        (local.on_future_grant_key) = {
          privileges = ["OWNERSHIP"]
        }
      }
      external_table_grants = {
        (local.on_future_grant_key) = {
          privileges = ["OWNERSHIP"]
        }
      }
      view_grants = {
        (local.on_future_grant_key) = {
          privileges = ["OWNERSHIP"]
        }
      }
      materialized_view_grants = {
        (local.on_future_grant_key) = {
          privileges = ["OWNERSHIP"]
        }
      }
      file_format_grants = {
        (local.on_future_grant_key) = {
          privileges = ["OWNERSHIP"]
        }
      }
      function_grants = {
        (local.on_future_grant_key) = {
          privileges = ["OWNERSHIP"]
        }
      }
      stage_grants = {
        (local.on_future_grant_key) = {
          privileges = ["OWNERSHIP"]
        }
      }
      task_grants = {
        (local.on_future_grant_key) = {
          privileges = ["OWNERSHIP"]
        }
      }
      procedure_grants = {
        (local.on_future_grant_key) = {
          privileges = ["OWNERSHIP"]
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

  readonly_role_enabled        = local.create_default_roles && try(local.roles["readonly"].enabled, true)
  readwrite_role_enabled       = local.create_default_roles && try(local.roles["readwrite"].enabled, true)
  read_classified_role_enabled = local.create_default_roles && try(local.roles["read_classified"].enabled, true)
  modify_role_enabled          = local.create_default_roles && try(local.roles["modify"].enabled, true)
  admin_role_enabled           = local.create_default_roles && try(local.roles["admin"].enabled, true)

  role_modules = merge(
    local.readonly_role_enabled ? { readonly = module.snowflake_readonly_role } : {},
    local.readwrite_role_enabled ? { readwrite = module.snowflake_readwrite_role } : {},
    local.read_classified_role_enabled ? { read_classified = module.snowflake_read_classified_role } : {},
    local.modify_role_enabled ? { modify = module.snowflake_modify_role } : {},
    local.admin_role_enabled ? { admin = module.snowflake_admin_role } : {},
    module.snowflake_custom_role
  )
}

module "roles_deep_merge" {
  source  = "Invicton-Labs/deepmerge/null"
  version = "0.1.5"

  maps = [local.default_roles, local.provided_roles]
}
