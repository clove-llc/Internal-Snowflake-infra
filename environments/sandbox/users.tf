# ユーザーは users.yaml で管理する(default_role ごとのグループ)。
# 対象外: SNOWFLAKE(Snowflake が管理するシステムユーザー)
locals {
  users_by_role = yamldecode(file("${path.module}/users.yaml"))

  users = merge([
    for role, users in local.users_by_role : {
      for u in users : u.name => merge(u, { default_role = role })
    }
  ]...)
}

resource "snowflake_user" "this" {
  for_each = local.users

  name                           = each.value.name
  login_name                     = try(each.value.login_name, each.value.name)
  display_name                   = try(each.value.display_name, null)
  first_name                     = try(each.value.first_name, null)
  last_name                      = try(each.value.last_name, null)
  email                          = try(each.value.email, null)
  comment                        = try(each.value.comment, null)
  default_role                   = each.value.default_role == "NONE" ? null : each.value.default_role
  default_warehouse              = try(each.value.default_warehouse, null)
  default_secondary_roles_option = try(each.value.default_secondary_roles_option, "ALL")
  disabled                       = try(each.value.disabled, false)

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
