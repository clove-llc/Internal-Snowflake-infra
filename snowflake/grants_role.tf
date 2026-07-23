# ロール付与は grants_role.yaml(ロール → ユーザーのリスト)で管理する
locals {
  grants_role = yamldecode(file("${path.module}/grants_role.yaml"))

  # for_each のキーは "ユーザー:ロール"(state のアドレスとして固定。変更すると再作成になる)
  role_grants = merge([
    for role, users in local.grants_role : {
      for user in users : "${user}:${role}" => { role = role, user = user }
    }
  ]...)
}

resource "snowflake_grant_account_role" "user" {
  for_each = local.role_grants

  role_name = each.value.role
  user_name = snowflake_user.this[each.value.user].name
}
