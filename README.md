# Snowflake Schema Terraform Module
![Snowflake](https://img.shields.io/badge/-SNOWFLAKE-249edc?style=for-the-badge&logo=snowflake&logoColor=white)
![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white)

![License](https://badgen.net/github/license/getindata/terraform-snowflake-schema/)
![Release](https://badgen.net/github/release/getindata/terraform-snowflake-schema/)

<p align="center">
  <img height="150" src="https://getindata.com/img/logo.svg">
  <h3 align="center">We help companies turn their data into assets</h3>
</p>

---

Terraform module for Snowflake schema management.

* Creates Snowflake schema
* Can create custom Snowflake database roles with role-to-role assignments
* Can create a set of default database roles to simplify access management:
  * `READONLY` - granted select on all tables and views and usage on some objects in the schema
  * `READWRITE` - granted write type grants on tables and stages. Additionally, allows calling procedures and tasks in the schema
  * `TRANSFORMER` - Allows creating tables and views on top of the `READWRITE` role privileges
  * `ADMIN` - Full access, including setting schema options like `data_retention_days`
  * Each role can be disabled seperately by setting `enabled` to false - see [Complete example](examples/complete)
  * Each role can be additionally modified - see [Complete example](examples/complete)

## USAGE

```terraform
module "snowflake_schema" {
  source = "github.com/getindata/terraform-snowflake-schema"
  # version = "x.x.x"

  name     = "MY_SCHEMA"
  database = "MY_DB"

  is_managed          = false
  is_transient        = false
  data_retention_days = 1

  create_default_database_roles = true
}
```

## EXAMPLES

- [Complete](examples/complete) - Advanced usage of the module
- [Simple](examples/simple) - Basic usage of the module

## Breaking changes in v2.x of the module
Due to breaking changes in Snowflake provider and additional code optimizations, **breaking changes** were introduced in `v2.0.0` version of this module.

List of code and variable (API) changes:
- Switched to `snowflake_database_role` module to leverage new `database_roles` mechanism
- stage module version was updated (`v2.1.0`) to use newly introduced changes by Snowflake provider
- overhaul of `roles` and `stages` variables
- variable `add_grants_to_existing_objects` was removed as it is no longer needed


When upgrading from `v1.x`, expect most of the resources to be recreated - if recreation is impossible, then it is possible to import some existing resources.

For more information, refer to [variables.tf](variables.tf), list of inputs below and Snowflake provider documentation

<!-- BEGIN_TF_DOCS -->

<!-- END_TF_DOCS -->

## CONTRIBUTING

Contributions are very welcomed!

Start by reviewing [contribution guide](CONTRIBUTING.md) and our [code of conduct](CODE_OF_CONDUCT.md). After that, start coding and ship your changes by creating a new PR.

## LICENSE

Apache 2 Licensed. See [LICENSE](LICENSE) for full details.

## AUTHORS

<!--- Replace repository name -->
<a href="https://github.com/getindata/REPO_NAME/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=getindata/terraform-snowflake-schema" />
</a>

Made with [contrib.rocks](https://contrib.rocks).
