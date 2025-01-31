resource "snowflake_account_role" "role_1" {
  name = "ROLE_1"
}

resource "snowflake_database_role" "db_role_1" {
  database = snowflake_database.this.name
  name     = "DB_ROLE_1"
}

resource "snowflake_database_role" "db_role_2" {
  database = snowflake_database.this.name
  name     = "DB_ROLE_2"
}

resource "snowflake_database_role" "db_role_3" {
  database = snowflake_database.this.name
  name     = "DB_ROLE_3"
}

resource "snowflake_database" "this" {
  name = "ANALYTICS_DB"
}

resource "snowflake_schema" "this" {
  name     = "existing"
  database = snowflake_database.this.name
}

resource "snowflake_table" "table_1" {
  database = snowflake_database.this.name
  schema   = module.raw_schema.name
  name     = "TEST_TABLE_1"

  column {
    name     = "identity"
    type     = "NUMBER(38,0)"
    nullable = true

    identity {
      start_num = 1
      step_num  = 3
    }
  }
}

resource "snowflake_table" "table_2" {
  database = snowflake_database.this.name
  schema   = module.raw_schema.name
  name     = "TEST_TABLE_2"

  column {
    name     = "identity"
    type     = "NUMBER(38,0)"
    nullable = true

    identity {
      start_num = 1
      step_num  = 3
    }
  }
}

module "existing_schema" {
  source            = "../../"
  context_templates = var.context_templates

  name     = snowflake_schema.this.name
  database = snowflake_database.this.name

  skip_schema_creation = true
  create_default_roles = true

}

module "raw_schema" {
  source            = "../../"
  context_templates = var.context_templates

  name     = "raw"
  database = snowflake_database.this.name

  with_managed_access         = false
  is_transient                = false
  data_retention_time_in_days = 1

  create_default_roles = true

  roles = {
    transformer = { # Modifies the default transformer role
      granted_to_roles = [snowflake_account_role.role_1.name]
      schema_objects_grants = {
        "EXTERNAL TABLE" = [
          {
            all_privileges    = true
            with_grant_option = true
            on_all            = true
            on_future         = false
          }
        ]
        "FILE FORMAT" = [
          {
            all_privileges    = true
            with_grant_option = false
            on_all            = false
            on_future         = true
          }
        ]
        "ICEBERG TABLE" = [
          {
            all_privileges = true
            on_all         = true
            on_future      = true
          }
        ]
      }
    }
    database_role_1 = {
      granted_to_database_roles = [
        "${snowflake_database.this.name}.${snowflake_database_role.db_role_1.name}",
        "${snowflake_database.this.name}.${snowflake_database_role.db_role_2.name}",
        "${snowflake_database.this.name}.${snowflake_database_role.db_role_3.name}"
      ]
      schema_grants = [
        {
          all_schemas_in_database = true
          all_privileges          = true
        }
      ]
      schema_objects_grants = {
        "ALERT" = [
          {
            all_privileges    = true
            with_grant_option = true
            on_all            = true
          }
        ]
      }
    }
  }

  stages = {
    my_stage = {
      comment = "Stage used to ingest data"

      create_default_roles = false
    }
    my_second_stage = {
      comment              = "Stage used to transform data from other source"
      create_default_roles = true
    }
    my_third_stage = {
      comment = "Stage used to transform data from other source"
    }
  }
}

module "marts_schema" {
  source            = "../../"
  context_templates = var.context_templates

  name = "marts"
  name_scheme = {
    uppercase = false
  }
  database = snowflake_database.this.name
}
