# environments/sandbox — 検証アカウント

検証用 Snowflake アカウント(`WFJVSLU-VT27190`)の資材。受講者・チュートリアルとは無関係に、このアカウントのリソースを Terraform で管理する。

## 接続設定

Terraform の実行は専用の **TERRAFORM ユーザー(ロール: SYSADMIN)**+ キーペア認証で行う。接続情報は環境変数で渡し、direnv で自動読み込みする(コード・tfvars に認証情報を書かない)。

```bash
brew install direnv                      # 未導入の場合(~/.zshrc に hook 追記も必要)
cp .envrc.example .envrc                 # 鍵パスを自分の環境に合わせる
direnv allow                             # このディレクトリに入ると自動で SNOWFLAKE_* が入る
```

`.envrc` は git 管理外。秘密鍵 `~/.snowflake/terraform_rsa_key.p8` は管理者から受け取る。

## 初回セットアップ(管理者が手動で実施)

ロール付与・鍵登録・所有権の移転は Terraform で管理せず、Snowsight から ACCOUNTADMIN で実行する。

```sql
USE ROLE ACCOUNTADMIN;

-- 1. TERRAFORM ユーザーに SYSADMIN を付与
GRANT ROLE SYSADMIN TO USER TERRAFORM;
ALTER USER TERRAFORM SET DEFAULT_ROLE = SYSADMIN;

-- 2. TERRAFORM ユーザーの公開鍵を登録(値は terraform_rsa_key.pub のヘッダー・フッターを除いた中身)
ALTER USER TERRAFORM SET RSA_PUBLIC_KEY='<公開鍵>';

-- 3. 管理対象オブジェクトの所有権を SYSADMIN へ(既存の権限は維持)
--    HARATO_DBT は元から SYSADMIN 所有のため対象外
GRANT OWNERSHIP ON DATABASE ADMIN_DB              TO ROLE SYSADMIN COPY CURRENT GRANTS;
GRANT OWNERSHIP ON DATABASE DATALAKE              TO ROLE SYSADMIN COPY CURRENT GRANTS;
GRANT OWNERSHIP ON DATABASE DATAMART              TO ROLE SYSADMIN COPY CURRENT GRANTS;
GRANT OWNERSHIP ON DATABASE DATAWAREHOUSE         TO ROLE SYSADMIN COPY CURRENT GRANTS;
GRANT OWNERSHIP ON DATABASE DEV_DATABASE          TO ROLE SYSADMIN COPY CURRENT GRANTS;
GRANT OWNERSHIP ON DATABASE DOCOMO_DB             TO ROLE SYSADMIN COPY CURRENT GRANTS;
GRANT OWNERSHIP ON DATABASE HARATO                TO ROLE SYSADMIN COPY CURRENT GRANTS;
GRANT OWNERSHIP ON DATABASE SNOWFLAKE_LEARNING_DB TO ROLE SYSADMIN COPY CURRENT GRANTS;
GRANT OWNERSHIP ON DATABASE USERDB_D_P01_LAK      TO ROLE SYSADMIN COPY CURRENT GRANTS;
GRANT OWNERSHIP ON WAREHOUSE STREAMLIT_WH         TO ROLE SYSADMIN COPY CURRENT GRANTS;

-- 4. users.yaml 管理対象ユーザーの所有権(SYSADMIN がユーザーを変更できるようにする)
GRANT OWNERSHIP ON USER CLOVEADMIN          TO ROLE SYSADMIN COPY CURRENT GRANTS;
GRANT OWNERSHIP ON USER DAISUKE_HARATO      TO ROLE SYSADMIN COPY CURRENT GRANTS;
GRANT OWNERSHIP ON USER SUZUKAZU0301        TO ROLE SYSADMIN COPY CURRENT GRANTS;
GRANT OWNERSHIP ON USER "YASUHIRO.TAKEMURA" TO ROLE SYSADMIN COPY CURRENT GRANTS;
GRANT OWNERSHIP ON USER "YOSHITAKA.ARAKI"   TO ROLE SYSADMIN COPY CURRENT GRANTS;
GRANT OWNERSHIP ON USER TERRAFORM           TO ROLE SYSADMIN COPY CURRENT GRANTS;
```

注意: 手順4により、SYSADMIN 保持者は ACCOUNTADMIN 保持者を含む各ユーザーを変更(パスワードリセット等)できるようになる。SYSADMIN の付与先は Terraform 運用者に限定すること。

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
| ユーザー | `users.tf` + `users.yaml` | システムユーザー SNOWFLAKE を除く全ユーザー |

## ユーザー管理(users.yaml)

ユーザーは `users.yaml` で管理する。`default_role` ごとのグループ(段落)にエントリを置く形式で、`name` 以外のキーは省略可(既定値は users.yaml 冒頭のコメント参照)。

- **追加**: 付与したい default_role の段落にエントリを足して apply。パスワード・公開鍵は Terraform で扱わないため、初期認証情報の設定は別途行う
- **変更**: 該当キーを書き換えて apply。段落間の移動 = default_role の変更
- **削除**: エントリを消して apply(**実ユーザーが DROP される**。plan で必ず確認)
- 公開鍵(rsa_public_key)と must_change_password 等の運用系属性は `ignore_changes` で管理対象外。各ユーザーが自分で登録・変更しても Terraform は関知しない

## 既存リソースの取り込み

手作業で作られたリソースを管理に入れる場合は、定義を書いてから import する。

```bash
terraform import snowflake_database.harato HARATO
terraform import 'snowflake_user.this["YAMADA.TARO"]' '"YAMADA.TARO"'
```

import 後に `terraform plan` を実行し、差分が出なくなるまで定義を実環境に合わせること(合わせずに apply すると実環境が書き換わる)。
