# docs/04 演習の解答

# 演習1: MART スキーマ + TUTORIAL_ANALYST への同等権限
resource "snowflake_schema" "mart" {
  database = snowflake_database.tutorial.name
  name     = "MART"
  comment  = "加工済みデータ置き場"
}

resource "snowflake_grant_privileges_to_account_role" "analyst_mart_schema" {
  account_role_name = snowflake_account_role.analyst.name
  privileges        = ["USAGE"]

  on_schema {
    schema_name = "\"${snowflake_database.tutorial.name}\".\"${snowflake_schema.mart.name}\""
  }
}

resource "snowflake_grant_privileges_to_account_role" "analyst_mart_tables" {
  account_role_name = snowflake_account_role.analyst.name
  privileges        = ["SELECT"]

  on_schema_object {
    future {
      object_type_plural = "TABLES"
      in_schema          = "\"${snowflake_database.tutorial.name}\".\"${snowflake_schema.mart.name}\""
    }
  }
}

# 演習2: TUTORIAL_ENGINEER ロール(DB への USAGE + CREATE SCHEMA)
resource "snowflake_account_role" "engineer" {
  name    = "TUTORIAL_ENGINEER"
  comment = "チュートリアル用: エンジニアロール"
}

resource "snowflake_grant_privileges_to_account_role" "engineer_db" {
  account_role_name = snowflake_account_role.engineer.name
  privileges        = ["USAGE", "CREATE SCHEMA"]

  on_account_object {
    object_type = "DATABASE"
    object_name = snowflake_database.tutorial.name
  }
}
