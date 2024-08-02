variable "skip_schema_creation" {
  description = <<EOF
    Should schema creation be skipped but allow all other resources to be created.
    Useful if schema already exsists but you want to add e.g. access roles."
    EOF
  type        = bool
  default     = false
}

variable "database" {
  description = "Database where the schema should be created"
  type        = string
}

variable "comment" {
  description = "Specifies a comment for the schema"
  type        = string
  default     = null
}

variable "data_retention_time_in_days" {
  description = <<EOF
    Specifies the number of days for which Time Travel actions (CLONE and UNDROP) can be performed on the schema,
    as well as specifying the default Time Travel retention time for all tables created in the schema
    EOF
  type        = number
  default     = 1
}

variable "is_transient" {
  description = <<EOF
    Specifies a schema as transient.
    Transient schemas do not have a Fail-safe period so they do not incur additional storage costs once they leave Time Travel; 
    however, this means they are also not protected by Fail-safe in the event of a data loss.
    EOF
  type        = bool
  default     = false
}

variable "with_managed_access" {
  description = "Specifies a managed schema. Managed access schemas centralize privilege management with the schema owner"
  type        = bool
  default     = false
}

variable "create_default_roles" {
  description = "Whether the default database roles should be created"
  type        = bool
  default     = false
}

variable "roles" {
  description = "Database roles created in the scheme scope"
  type = map(object({
    enabled                   = optional(bool, true)
    descriptor_name           = optional(string, "snowflake-database-role")
    role_ownership_grant      = optional(string)
    granted_to_roles          = optional(list(string))
    granted_to_database_roles = optional(list(string))
    granted_database_roles    = optional(list(string))
    database_grants = optional(object({
      all_privileges    = optional(bool)
      with_grant_option = optional(bool, false)
      privileges        = optional(list(string), null)
    }))
    schema_grants = optional(list(object({
      all_privileges             = optional(bool)
      with_grant_option          = optional(bool, false)
      privileges                 = optional(list(string), null)
      all_schemas_in_database    = optional(bool, false)
      future_schemas_in_database = optional(bool, false)
      schema_name                = optional(string, null)
    })))
    schema_objects_grants = optional(map(list(object({
      all_privileges    = optional(bool)
      with_grant_option = optional(bool)
      privileges        = optional(list(string), null)
      object_name       = optional(string)
      on_all            = optional(bool, false)
      schema_name       = optional(string)
      on_future         = optional(bool, false)
    }))), {})
  }))
  default = {}
}

variable "stages" {
  description = "Stages to be created in the schema"
  type = map(object({
    enabled             = optional(bool, true)
    descriptor_name     = optional(string, "snowflake-stage")
    aws_external_id     = optional(string)
    comment             = optional(string)
    copy_options        = optional(string)
    credentials         = optional(string)
    directory           = optional(string)
    encryption          = optional(string)
    file_format         = optional(string)
    snowflake_iam_user  = optional(string)
    storage_integration = optional(string)
    url                 = optional(string)
    roles = optional(map(object({
      descriptor_name           = optional(string, "snowflake-database-role")
      with_grant_option         = optional(bool)
      granted_to_roles          = optional(list(string))
      granted_to_database_roles = optional(list(string))
      granted_database_roles    = optional(list(string))
      stage_grants              = optional(list(string))
      all_privileges            = optional(bool)
      on_all                    = optional(bool, false)
      schema_name               = optional(string)
      on_future                 = optional(bool, false)
    })), ({}))
    create_default_roles = optional(bool, false)
  }))
  default = {}
}

variable "descriptor_name" {
  description = "Name of the descriptor used to form a resource name"
  type        = string
  default     = "snowflake-schema"
}

variable "catalog" {
  description = "Parameter that specifies the default catalog to use for Iceberg tables."
  type        = string
  default     = null
}

variable "default_ddl_collation" {
  description = <<-EOT
    Specifies a default collation specification for all schemas and tables added to the database.
    It can be overridden on schema or table level.
  EOT
  type        = string
  default     = null
}

variable "external_volume" {
  description = "Parameter that specifies the default external volume to use for Iceberg tables."
  type        = string
  default     = null
}

variable "log_level" {
  description = <<-EOT
    Specifies the severity level of messages that should be ingested and made available in the active event table.
    Valid options are: [TRACE DEBUG INFO WARN ERROR FATAL OFF].
    Messages at the specified level (and at more severe levels) are ingested.
  EOT
  type        = string
  default     = null
}

variable "max_data_extension_time_in_days" {
  description = <<-EOT
    Object parameter that specifies the maximum number of days for which Snowflake can extend the data retention period 
    for tables in the database to prevent streams on the tables from becoming stale.
  EOT
  type        = number
  default     = null
}

variable "quoted_identifiers_ignore_case" {
  description = "If true, the case of quoted identifiers is ignored."
  type        = bool
  default     = null
}

variable "replace_invalid_characters" {
  description = <<-EOT
    Specifies whether to replace invalid UTF-8 characters with the Unicode replacement character () in query results for an Iceberg table.
    You can only set this parameter for tables that use an external Iceberg catalog.
  EOT
  type        = bool
  default     = null
}

variable "storage_serialization_policy" {
  description = <<-EOT
    The storage serialization policy for Iceberg tables that use Snowflake as the catalog.
    Valid options are: [COMPATIBLE OPTIMIZED].
  EOT
  type        = string
  default     = null
}

variable "trace_level" {
  description = <<-EOT
    Controls how trace events are ingested into the event table.
    Valid options are: [ALWAYS ON_EVENT OFF]."
  EOT
  type        = string
  default     = null
}

variable "suspend_task_after_num_failures" {
  description = "How many times a task must fail in a row before it is automatically suspended. 0 disables auto-suspending."
  type        = number
  default     = null
}

variable "task_auto_retry_attempts" {
  description = "Maximum automatic retries allowed for a user task."
  type        = number
  default     = null
}

variable "user_task_managed_initial_warehouse_size" {
  description = "The initial size of warehouse to use for managed warehouses in the absence of history."
  type        = string
  default     = null
}

variable "user_task_timeout_ms" {
  description = "User task execution timeout in milliseconds."
  type        = number
  default     = null
}

variable "user_task_minimum_trigger_interval_in_seconds" {
  description = "Minimum amount of time between Triggered Task executions in seconds."
  type        = number
  default     = null
}

variable "enable_console_output" {
  description = "Enables console output for user tasks."
  type        = bool
  default     = null
}

variable "pipe_execution_paused" {
  description = "Pauses the execution of a pipe."
  type        = bool
  default     = null
}
