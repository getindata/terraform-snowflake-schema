output "name" {
  description = "Name of the schema"
  value       = one(snowflake_schema.this[*].name)
}

output "data_retention_days" {
  description = "Data retention days for the schema"
  value       = one(snowflake_schema.this[*].data_retention_days)
}

output "is_transient" {
  description = "Is schema transient"
  value       = one(snowflake_schema.this[*].is_transient)
}

output "is_managed" {
  description = "Is schema managed"
  value       = one(snowflake_schema.this[*].is_managed)
}

output "database" {
  description = "Database where the schema is deployed to"
  value       = one(snowflake_schema.this[*].database)
}

output "stages" {
  description = "Schema stages"
  value       = module.snowflake_stage
}

output "roles" {
  description = "Snowflake Roles"
  value       = local.roles
}

output "roles_grant_on_all_statements" {
  description = <<EOT
    Generates GRANT ON ALL type of statements according to provided role definitions.
    This is useful if the module is created with `skip_schema_creation` option in cases like zero-copy clone
    and all access roles are meant to be created.
    Related Snowflake provider GitHub issue:
    https://github.com/Snowflake-Labs/terraform-provider-snowflake/issues/250
  EOT
  value       = local.roles_grant_on_all_statements
}

output "roles_revoke_on_all_statements" {
  description = <<EOT
    Generates REVOKE ON ALL type of statements according to provided role definitions.
    This is useful if the module is created with `skip_schema_creation` option in cases like zero-copy clone
    and all access roles are meant to be created.
    Related Snowflake provider GitHub issue:
    https://github.com/Snowflake-Labs/terraform-provider-snowflake/issues/250
  EOT
  value       = local.roles_revoke_on_all_statements
}
