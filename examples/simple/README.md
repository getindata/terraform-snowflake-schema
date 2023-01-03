# Complete Example

```terraform
resource "snowflake_database" "test" {
  name = "ANALYTICS_DB"
}

module "this_schema" {
  source = "../../"

  name     = "RAW"
  database = snowflake_database.test.name
}
```

## Usage
Populate `.env` file with Snowflake credentials and make sure it's sourced to your shell.

```
terraform init
terraform plan -out tfplan
terraform apply tfplan
```
