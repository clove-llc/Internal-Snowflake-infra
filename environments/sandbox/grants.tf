# TERRAFORM ユーザーは SYSADMIN で運用する(default_role は users.yaml 側)
resource "snowflake_grant_account_role" "terraform_sysadmin" {
  role_name = "SYSADMIN"
  user_name = snowflake_user.this["TERRAFORM"].name
}
