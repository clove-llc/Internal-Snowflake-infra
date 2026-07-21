resource "snowflake_warehouse" "tutorial" {
  name           = "${local.prefix}_WH"
  comment        = "Terraform チュートリアル用ウェアハウス(${var.env})"
  warehouse_size = var.warehouse_size

  auto_suspend        = 60
  auto_resume         = true
  initially_suspended = true
}
