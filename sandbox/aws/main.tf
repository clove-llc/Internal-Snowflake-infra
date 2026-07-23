terraform {
  required_version = ">= 1.10" # S3 ネイティブロック(use_lockfile)のため

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.56.0"
    }
  }
}

provider "aws" {
  # 認証情報とリージョンは環境変数(AWS_*)から読む
}
