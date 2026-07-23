terraform {
  required_version = ">= 1.10" # S3 ネイティブロック(use_lockfile)のため

  backend "s3" {
    bucket       = "clove-llc-terraform-state"
    key          = "sandbox/snowflake/terraform.tfstate"
    region       = "ap-northeast-1"
    use_lockfile = true
  }

  required_providers {
    snowflake = {
      source  = "snowflakedb/snowflake"
      version = "2.18.0"
    }
  }

  # state は当面ローカル(管理者運用)。リモートバックエンド移行は docs/07 の TODO
}

provider "snowflake" {
  # 接続情報は環境変数 SNOWFLAKE_* から読む。apply は ACCOUNTADMIN で行う(README 参照)
}
