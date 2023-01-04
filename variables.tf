variable "database" {
  description = "Database where the schema should be created"
  type        = string
}

variable "comment" {
  description = "Specifies a comment for the schema"
  type        = string
  default     = null
}

variable "data_retention_days" {
  description = "Specifies the number of days for which Time Travel actions (CLONE and UNDROP) can be performed on the schema, as well as specifying the default Time Travel retention time for all tables created in the schema"
  type        = number
  default     = 1
}

variable "is_transient" {
  description = "Specifies a schema as transient. Transient schemas do not have a Fail-safe period so they do not incur additional storage costs once they leave Time Travel; however, this means they are also not protected by Fail-safe in the event of a data loss"
  type        = bool
  default     = false
}

variable "is_managed" {
  description = "Specifies a managed schema. Managed access schemas centralize privilege management with the schema owner"
  type        = bool
  default     = false
}

variable "create_default_roles" {
  description = "Whether the default roles should be created"
  type        = bool
  default     = false
}

variable "roles" {
  description = "Roles created in the scheme scope"
  type = map(object({
    enabled              = optional(bool, true)
    comment              = optional(string)
    role_ownership_grant = optional(string)
    granted_roles        = optional(list(string), [])
    granted_to_roles     = optional(list(string), [])
    granted_to_users     = optional(list(string), [])
    schema_grants = optional(object({
      privileges = list(string)
    }), { privileges = [] })
    table_grants = optional(map(object({
      privileges = list(string)
    })), {})
    external_table_grants = optional(map(object({
      privileges = list(string)
    })), {})
    view_grants = optional(map(object({
      privileges = list(string)
    })), {})
    materialized_view_grants = optional(map(object({
      privileges = list(string)
    })), {})
    file_format_grants = optional(map(object({
      privileges = list(string)
    })), {})
    function_grants = optional(map(object({
      privileges = list(string)
    })), {})
    stage_grants = optional(map(object({
      privileges = list(string)
    })), {})
    task_grants = optional(map(object({
      privileges = list(string)
    })), {})
    procedure_grants = optional(map(object({
      privileges = list(string)
    })), {})
    sequence_grants = optional(map(object({
      privileges = list(string)
    })), {})
    sequence_grants = optional(map(object({
      privileges = list(string)
    })), {})
  }))
  default = {}
}

variable "descriptor_name" {
  description = "Name of the descriptor used to form a resource name"
  type        = string
  default     = "snowflake-schema"
}
