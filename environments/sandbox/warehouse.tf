# 既存リソースを import で管理下に入れたもの(README 参照)
resource "snowflake_warehouse" "streamlit" {
  name           = "STREAMLIT_WH"
  warehouse_type = "STANDARD"
  warehouse_size = "XSMALL"
  generation     = "2"
  auto_suspend   = 60
  auto_resume    = true
}
