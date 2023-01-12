resource "snowflake_user" "dbt" {
  name       = "DBT user"
  login_name = "dbt_user"
  comment    = "DBT user."
}

resource "snowflake_role" "admin" {
  name    = "ADMIN"
  comment = "Role for Snowflake Administrators"
}

resource "snowflake_role" "dev" {
  name    = "DEV"
  comment = "Role for Snowflake Developers"
}

resource "snowflake_database" "test" {
  name = "ANALYTICS_DB"
}

module "this_schema" {
  source  = "../../"
  context = module.this.context

  name     = "raw"
  database = snowflake_database.test.name

  is_managed          = false
  is_transient        = false
  data_retention_days = 1

  stages = {
    my_stage = {}
  }

  create_default_roles = true
  roles = {
    admin = {
      granted_to_roles = [snowflake_role.admin.name]
    }
    readwrite = {
      granted_to_users = [snowflake_user.dbt.name]
    }
    readonly = {
      granted_to_roles = [snowflake_role.dev.name]
    }
    read_classified = {
      enabled = false
    }
    custom_access = {
      granted_to_users = [snowflake_user.dbt.name]
    }
  }
}
