locals {
  # 例: env = "dev" → "DEV_TUTORIAL"
  prefix = "${upper(var.env)}_TUTORIAL"
}
