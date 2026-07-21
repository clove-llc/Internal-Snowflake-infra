output "learner_role_name" {
  description = "受講者に付与するロール名"
  value       = snowflake_account_role.tutorial_learner.name
}
