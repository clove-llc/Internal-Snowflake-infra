# チュートリアル受講者用ロール
# 受講者はこのロールで演習リソース(DB・WH・ロール)を作成する。
# 自分で作成したオブジェクトは所有権を持つため、演習内のグラント操作に追加権限は不要。
resource "snowflake_account_role" "tutorial_learner" {
  name    = "TUTORIAL_LEARNER"
  comment = "チュートリアル受講者用。演習リソースの作成権限を持つ"
}

resource "snowflake_grant_privileges_to_account_role" "learner_account" {
  account_role_name = snowflake_account_role.tutorial_learner.name
  privileges        = ["CREATE DATABASE", "CREATE WAREHOUSE", "CREATE ROLE"]
  on_account        = true
}
