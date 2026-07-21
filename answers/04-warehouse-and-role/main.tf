terraform {
  required_version = ">= 1.5"

  required_providers {
    snowflake = {
      source  = "snowflakedb/snowflake"
      version = "2.18.0"
    }
  }
}

provider "snowflake" {
  # 接続情報は環境変数 SNOWFLAKE_* から読む(docs/01 参照)
}
