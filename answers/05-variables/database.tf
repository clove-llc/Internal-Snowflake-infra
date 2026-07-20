resource "snowflake_database" "tutorial" {
  name    = "${local.prefix}_DB"
  comment = "Terraform チュートリアル用データベース(${var.env})"
}

resource "snowflake_schema" "raw" {
  database = snowflake_database.tutorial.name
  name     = "RAW"
  comment  = "生データ置き場"
}
