resource "snowflake_warehouse" "tutorial" {
  name           = "TUTORIAL_WH"
  comment        = "Terraform チュートリアル用ウェアハウス"
  warehouse_size = "XSMALL"

  auto_suspend        = 60
  auto_resume         = true
  initially_suspended = true
}
