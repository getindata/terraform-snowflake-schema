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

output "name" {
  description = "Name of the schema"
  value       = one(snowflake_schema.this[*].name)
}

output "schema_comment" {
  description = "Comment of the schema"
  value       = one(snowflake_schema.this[*].comment)
}

output "schema_database" {
  description = "Database where the schema is deployed to"
  value       = one(snowflake_schema.this[*].database)
}

output "schema_is_transient" {
  description = "Is the schema transient"
  value       = one(snowflake_schema.this[*].is_transient)
}

output "schema_data_retention_time_in_days" {
  description = "Data retention time in days for the schema"
  value       = one(snowflake_schema.this[*].data_retention_time_in_days)
}

output "schema_with_managed_access" {
  description = "Whether the schema has managed access"
  value       = one(snowflake_schema.this[*].with_managed_access)
}

output "schema_max_data_extension_time_in_days" {
  description = "Maximum data extension time in days for the schema"
  value       = one(snowflake_schema.this[*].max_data_extension_time_in_days)
}

output "schema_external_volume" {
  description = "External volume for the schema"
  value       = one(snowflake_schema.this[*].external_volume)
}

output "schema_catalog" {
  description = "Catalog for the schema"
  value       = one(snowflake_schema.this[*].catalog)
}

output "schema_replace_invalid_characters" {
  description = "Whether to replace invalid characters for the schema"
  value       = one(snowflake_schema.this[*].replace_invalid_characters)
}

output "schema_default_ddl_collation" {
  description = "Default DDL collation for the schema"
  value       = one(snowflake_schema.this[*].default_ddl_collation)
}

output "schema_storage_serialization_policy" {
  description = "Storage serialization policy for the schema"
  value       = one(snowflake_schema.this[*].storage_serialization_policy)
}

output "schema_log_level" {
  description = "Log level for the schema"
  value       = one(snowflake_schema.this[*].log_level)
}

output "schema_trace_level" {
  description = "Trace level for the schema"
  value       = one(snowflake_schema.this[*].trace_level)
}

output "schema_suspend_task_after_num_failures" {
  description = "Number of task failures after which to suspend the task for the schema"
  value       = one(snowflake_schema.this[*].suspend_task_after_num_failures)
}

output "schema_task_auto_retry_attempts" {
  description = "Number of task auto retry attempts for the schema"
  value       = one(snowflake_schema.this[*].task_auto_retry_attempts)
}

output "schema_user_task_managed_initial_warehouse_size" {
  description = "User task managed initial warehouse size for the schema"
  value       = one(snowflake_schema.this[*].user_task_managed_initial_warehouse_size)
}

output "schema_user_task_timeout_ms" {
  description = "User task timeout in milliseconds for the schema"
  value       = one(snowflake_schema.this[*].user_task_timeout_ms)
}

output "schema_user_task_minimum_trigger_interval_in_seconds" {
  description = "User task minimum trigger interval in seconds for the schema"
  value       = one(snowflake_schema.this[*].user_task_minimum_trigger_interval_in_seconds)
}

output "schema_quoted_identifiers_ignore_case" {
  description = "Whether to ignore case for quoted identifiers for the schema"
  value       = one(snowflake_schema.this[*].quoted_identifiers_ignore_case)
}

output "schema_enable_console_output" {
  description = "Whether to enable console output for the schema"
  value       = one(snowflake_schema.this[*].enable_console_output)
}

output "schema_pipe_execution_paused" {
  description = "Whether to pause pipe execution for the schema"
  value       = one(snowflake_schema.this[*].pipe_execution_paused)
}
