variable "skip_schema_creation" {
  description = <<EOF
    "Should schema creation be skipped but allow all other resources to be created. 
    Useful if schema already exsists but you want to add e.g. access roles"
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
    "Specifies the number of days for which Time Travel actions (CLONE and UNDROP) can be performed on the schema, 
    as well as specifying the default Time Travel retention time for all tables created in the schema"
    EOF
  type        = number
  default     = 1
}

variable "is_transient" {
  description = <<EOF
    "Specifies a schema as transient. 
    Transient schemas do not have a Fail-safe period so they do not incur additional storage costs once they leave Time Travel; 
    however, this means they are also not protected by Fail-safe in the event of a data loss"
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
    create_default_stage_roles = optional(bool, false)
  }))
  default = {}
}

variable "descriptor_name" {
  description = "Name of the descriptor used to form a resource name"
  type        = string
  default     = "snowflake-schema"
}
