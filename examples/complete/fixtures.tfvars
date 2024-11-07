context_templates = {
  snowflake-stage                = "{{.name}}"
  snowflake-schema               = "{{.name}}"
  snowflake-schema-database-role = "{{.schema}}_{{.name}}"
  snowflake-project-schema       = "{{.project}}_{{.name}}"
}
