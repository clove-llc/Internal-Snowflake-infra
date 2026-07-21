# 既存リソースを import で管理下に入れたもの(README 参照)
# 対象外: SNOWFLAKE(アプリケーション)、SNOWFLAKE_SAMPLE_DATA(共有)、USER$*(個人用)

resource "snowflake_database" "admin_db" {
  name = "ADMIN_DB"
}

resource "snowflake_database" "datalake" {
  name                        = "DATALAKE"
  data_retention_time_in_days = 1
}

resource "snowflake_database" "datamart" {
  name                        = "DATAMART"
  data_retention_time_in_days = 1
}

resource "snowflake_database" "datawarehouse" {
  name                        = "DATAWAREHOUSE"
  data_retention_time_in_days = 1
}

resource "snowflake_database" "dev_database" {
  name = "DEV_DATABASE"
}

resource "snowflake_database" "docomo_db" {
  name = "DOCOMO_DB"
}

resource "snowflake_database" "harato" {
  name = "HARATO"
}

resource "snowflake_database" "harato_dbt" {
  name    = "HARATO_DBT"
  comment = "Database for dbt Projects on Snowflake"
}

resource "snowflake_database" "snowflake_learning_db" {
  name    = "SNOWFLAKE_LEARNING_DB"
  comment = "Created by Snowflake during account provisioning"
}

resource "snowflake_database" "userdb_d_p01_lak" {
  name = "USERDB_D_P01_LAK"
}
