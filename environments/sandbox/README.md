# environments/sandbox — 検証アカウント

検証用 Snowflake アカウント(`WFJVSLU-VT27190`)の資材。受講者・チュートリアルとは無関係に、このアカウントのリソースを Terraform で管理する。

## 接続設定

キーペア認証。環境変数で渡す(コード・tfvars に認証情報を書かない)。

```bash
export SNOWFLAKE_ORGANIZATION_NAME="WFJVSLU"
export SNOWFLAKE_ACCOUNT_NAME="VT27190"
export SNOWFLAKE_USER="DAISUKE_HARATO"
export SNOWFLAKE_AUTHENTICATOR="SNOWFLAKE_JWT"
export SNOWFLAKE_PRIVATE_KEY="$(cat $HOME/.snowflake/clove_dcc.p8)"
export SNOWFLAKE_ROLE="ACCOUNTADMIN"
```

秘密鍵は dbt(docomo_event_sf の profiles.yml)と共用。ロールの ACCOUNTADMIN 常用は暫定で、サービスユーザー化は TODO(tutorial/docs/07)。

## 適用手順

```bash
terraform init
terraform plan
terraform apply
```

state は当面ローカル。`*.tfstate` は git 管理外なので保管に注意する。

## 既存リソースの取り込み

このアカウントには手作業で作られたリソースがある。Terraform 管理に入れる場合は、リソース定義を書いてから import する。

```bash
terraform import snowflake_database.harato HARATO
terraform import snowflake_warehouse.streamlit STREAMLIT_WH
```

import 後に `terraform plan` を実行し、差分が出なくなるまで定義を実環境に合わせること(合わせずに apply すると実環境が書き換わる)。
