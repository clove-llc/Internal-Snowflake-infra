output "database_name" {
  description = "作成されたデータベース名"
  value       = snowflake_database.tutorial.name
}

output "warehouse_name" {
  description = "作成されたウェアハウス名"
  value       = snowflake_warehouse.tutorial.name
}

output "analyst_role_name" {
  description = "分析者ロール名。dbt の profiles.yml などで参照する"
  value       = snowflake_account_role.analyst.name
}
