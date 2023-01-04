resource "snowflake_database" "test" {
  name = "ANALYTICS_DB"
}

module "this_schema" {
  source = "../../"

  name     = "RAW"
  database = snowflake_database.test.name
}
