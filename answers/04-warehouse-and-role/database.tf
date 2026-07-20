resource "snowflake_database" "tutorial" {
  name    = "TUTORIAL_DB"
  comment = "Terraform チュートリアル用データベース"
}

resource "snowflake_schema" "raw" {
  database = snowflake_database.tutorial.name
  name     = "RAW"
  comment  = "生データ置き場"
}
