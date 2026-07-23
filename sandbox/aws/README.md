# sandbox/aws — AWS 資材

clove-llc の AWS アカウント(`390402559560`)の資材。現在の管理対象は Terraform state 用の S3 バケット(`clove-terraform-state`)のみ。

## セットアップ

認証はアクセスキーではなく **`aws login`(ブラウザサインイン)** を使う。取得される一時認証情報は最大12時間有効で、CLI・Terraform の両方から使われる。前提: AWS CLI 2.32.0 以上。

### 1. IAM 側の準備(初回のみ・管理者)

サインインする IAM ユーザーに以下のポリシーをアタッチする。

- `SignInLocalDevelopmentAccess`(AWS 管理ポリシー。`aws login` に必須)
- S3 の操作権限(`AmazonS3FullAccess` など。state バケットの作成・読み書き用)

### 2. プロファイルと接続設定(初回のみ)

```bash
# ~/.aws/config に追記
[profile clove]
region = ap-northeast-1
```

```bash
cp .envrc.example .envrc   # AWS_PROFILE=clove を使う。アクセスキーの記入は不要
direnv allow
```

### 3. サインイン(セッション切れのたびに実行)

```bash
aws login --profile clove
# ブラウザが開くので clove-llc(390402559560)の IAM ユーザーでサインイン

aws sts get-caller-identity   # Account が 390402559560 になっていればOK
```

セッションは最大12時間。`ExpiredToken` 系のエラーが出たら再度 `aws login --profile clove`。終了は `aws logout`。

### 4. バケットの作成(ブートストラップ・初回のみ)

state 置き場を作る Terraform 自身の state は、初回はローカルに作られる。

```bash
terraform init
terraform plan
terraform apply
```

### 5. state の S3 移行(初回のみ)

バケットができたら、sandbox/aws と sandbox/snowflake の両方に backend 設定を追加して移行する。

```hcl
# それぞれの main.tf の terraform ブロック内に追加
backend "s3" {
  bucket       = "clove-terraform-state"
  key          = "sandbox/aws/terraform.tfstate" # snowflake 側は "sandbox/snowflake/terraform.tfstate"
  region       = "ap-northeast-1"
  use_lockfile = true
}
```

```bash
terraform init -migrate-state   # ローカル state を S3 へ移す。両ディレクトリで実行
terraform plan                  # No changes を確認
```

移行後、ローカルの `terraform.tfstate`(と `.backup`)は残骸なので、plan の確認が済んだら削除してよい。
