# ユーザーは users.csv で管理する。行を追加して apply するとユーザーが作られる。
# 対象外: SNOWFLAKE(Snowflake が管理するシステムユーザー)
# パスワード・公開鍵は Terraform では扱わない(各ユーザーが自分で設定する)。
locals {
  users = { for u in csvdecode(file("${path.module}/users.csv")) : u.name => u }
}

resource "snowflake_user" "this" {
  for_each = local.users

  name                           = each.value.name
  login_name                     = each.value.login_name
  display_name                   = each.value.display_name != "" ? each.value.display_name : null
  first_name                     = each.value.first_name != "" ? each.value.first_name : null
  last_name                      = each.value.last_name != "" ? each.value.last_name : null
  email                          = each.value.email != "" ? each.value.email : null
  comment                        = each.value.comment != "" ? each.value.comment : null
  default_role                   = each.value.default_role != "" ? each.value.default_role : null
  default_warehouse              = each.value.default_warehouse != "" ? each.value.default_warehouse : null
  default_secondary_roles_option = each.value.default_secondary_roles_option
  disabled                       = each.value.disabled

  lifecycle {
    # 公開鍵は各ユーザーが自分で登録・ローテーションする(Terraform で消さない)
    # must_change_password 以下は運用時に手動で操作する属性のため管理対象外
    ignore_changes = [
      rsa_public_key,
      rsa_public_key_2,
      must_change_password,
      mins_to_unlock,
      mins_to_bypass_mfa,
      disable_mfa,
    ]
  }
}
