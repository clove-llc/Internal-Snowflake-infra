# aws — AWS 資材

clove-llc の AWS アカウント(`390402559560`)の資材。現在の管理対象は Terraform state 用の S3 バケット(`clove-terraform-state`)のみ。

## セットアップ

### 1. IAM ユーザーとアクセスキー(初回のみ・AWS コンソール)

管理者権限のある IAM ユーザーでアクセスキーを発行する(将来的には Terraform 専用 IAM ユーザーに分離する)。

### 2. 接続設定

```bash
cp .envrc.example .envrc   # アクセスキーを記入
direnv allow
```

### 3. バケットの作成(ブートストラップ)

state 置き場を作る Terraform 自身の state は、初回はローカルに作られる。

```bash
terraform init
terraform plan
terraform apply
```

### 4. state の S3 移行

バケットができたら、aws/ と snowflake/ の両方に backend 設定を追加して移行する。

```hcl
# それぞれの main.tf の terraform ブロック内に追加
backend "s3" {
  bucket       = "clove-terraform-state"
  key          = "aws/terraform.tfstate" # snowflake/ では "snowflake/terraform.tfstate"
  region       = "ap-northeast-1"
  use_lockfile = true
}
```

```bash
terraform init -migrate-state   # ローカル state を S3 へ移す。両ディレクトリで実行
terraform plan                  # No changes を確認
```

移行後、ローカルの `terraform.tfstate`(と `.backup`)は残骸なので、plan の確認が済んだら削除してよい。
