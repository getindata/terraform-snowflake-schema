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
