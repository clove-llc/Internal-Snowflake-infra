variable "env" {
  description = "環境名(dev / prod など)。リソース名のプレフィックスに使う"
  type        = string
}

variable "warehouse_size" {
  description = "ウェアハウスのサイズ"
  type        = string
  default     = "XSMALL"

  validation {
    condition     = contains(["XSMALL", "SMALL", "MEDIUM"], var.warehouse_size)
    error_message = "コスト管理のため MEDIUM 以下にすること。"
  }
}
