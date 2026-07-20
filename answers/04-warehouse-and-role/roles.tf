resource "snowflake_account_role" "analyst" {
  name    = "TUTORIAL_ANALYST"
  comment = "チュートリアル用: 分析者ロール"
}

# 1段目: DB への USAGE
resource "snowflake_grant_privileges_to_account_role" "analyst_db" {
  account_role_name = snowflake_account_role.analyst.name
  privileges        = ["USAGE"]

  on_account_object {
    object_type = "DATABASE"
    object_name = snowflake_database.tutorial.name
  }
}

# クエリ実行に必要な WH への USAGE
resource "snowflake_grant_privileges_to_account_role" "analyst_wh" {
  account_role_name = snowflake_account_role.analyst.name
  privileges        = ["USAGE"]

  on_account_object {
    object_type = "WAREHOUSE"
    object_name = snowflake_warehouse.tutorial.name
  }
}

# 2段目: スキーマへの USAGE
resource "snowflake_grant_privileges_to_account_role" "analyst_schema" {
  account_role_name = snowflake_account_role.analyst.name
  privileges        = ["USAGE"]

  on_schema {
    schema_name = "\"${snowflake_database.tutorial.name}\".\"${snowflake_schema.raw.name}\""
  }
}

# 3段目: 今後作られるテーブルも含めた SELECT
resource "snowflake_grant_privileges_to_account_role" "analyst_tables" {
  account_role_name = snowflake_account_role.analyst.name
  privileges        = ["SELECT"]

  on_schema_object {
    future {
      object_type_plural = "TABLES"
      in_schema          = "\"${snowflake_database.tutorial.name}\".\"${snowflake_schema.raw.name}\""
    }
  }
}
