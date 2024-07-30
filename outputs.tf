output "name" {
  description = "Name of the schema"
  value       = one(snowflake_schema.this[*].name)
}

output "database" {
  description = "Database where the schema is deployed to"
  value       = one(snowflake_schema.this[*].database)
}

output "stages" {
  description = "Schema stages"
  value       = module.snowflake_stage
}

output "database_roles" {
  description = "Snowflake Database Roles"
  value       = local.roles
}

output "schema" {
  description = "Details of the schema"
  value       = one(resource.snowflake_schema.this[*])
}
