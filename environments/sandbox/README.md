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

## 管理対象

| 種別 | 定義 | 内容 |
|---|---|---|
| データベース | `databases.tf` | STANDARD の全10個(SNOWFLAKE / SNOWFLAKE_SAMPLE_DATA / USER$* は対象外) |
| ウェアハウス | `warehouse.tf` | STREAMLIT_WH |
| ユーザー | `users.tf` + `users.csv` | システムユーザー SNOWFLAKE を除く全ユーザー |

## ユーザー管理(users.csv)

ユーザーは `users.csv` の行として管理する。

- **追加**: 行を足して apply。パスワード・公開鍵は Terraform で扱わないため、初期認証情報の設定は別途行う
- **変更**: 該当セルを書き換えて apply(default_role / default_warehouse / disabled など)
- **削除**: 行を消して apply(**実ユーザーが DROP される**。plan で必ず確認)
- 公開鍵(rsa_public_key)と must_change_password 等の運用系属性は `ignore_changes` で管理対象外。各ユーザーが自分で登録・変更しても Terraform は関知しない

## 既存リソースの取り込み

手作業で作られたリソースを管理に入れる場合は、定義を書いてから import する。

```bash
terraform import snowflake_database.harato HARATO
terraform import 'snowflake_user.this["YAMADA.TARO"]' '"YAMADA.TARO"'
```

import 後に `terraform plan` を実行し、差分が出なくなるまで定義を実環境に合わせること(合わせずに apply すると実環境が書き換わる)。
