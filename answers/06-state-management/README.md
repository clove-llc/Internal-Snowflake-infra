# 06章 演習の解答

この章の演習は新しいコードを書かず、[answers/05-variables](../05-variables/) のコードをそのまま使う。以下は各ステップの期待される結果と、そこで確認すべきこと。

## 1. 環境の作成

```bash
cd answers/05-variables
terraform init
terraform apply -var-file=dev.tfvars
```

`Apply complete! Resources: 8 added` になる(DB 1 + スキーマ 1 + WH 1 + ロール 1 + グラント 4)。

## 2. terraform state list

```bash
terraform state list
```

期待される出力(順不同):

```
snowflake_account_role.analyst
snowflake_database.tutorial
snowflake_grant_privileges_to_account_role.analyst_db
snowflake_grant_privileges_to_account_role.analyst_schema
snowflake_grant_privileges_to_account_role.analyst_tables
snowflake_grant_privileges_to_account_role.analyst_wh
snowflake_schema.raw
snowflake_warehouse.tutorial
```

ここで見えるのは **Terraform リソース名**(`snowflake_database.tutorial`)であって Snowflake 上の名前(`DEV_TUTORIAL_DB`)ではない。コード上の名前と実環境の名前が別物であることが state の一覧からも確認できる。

## 3. terraform state show

```bash
terraform state show snowflake_database.tutorial
```

```
# snowflake_database.tutorial:
resource "snowflake_database" "tutorial" {
    comment = "Terraform チュートリアル用データベース(dev)"
    name    = "DEV_TUTORIAL_DB"
    ...
}
```

自分が書いていない引数(各種デフォルト値)まで記録されている点に注目。Terraform は「実環境の完全なスナップショット」を差分計算の基準として持っている。

## 4. 手作業リソースが検出されないことの確認

Snowsight で実行:

```sql
CREATE DATABASE MANUAL_DB;
```

その後:

```bash
terraform plan -var-file=dev.tfvars
```

期待される結果は **`No changes.`**。MANUAL_DB について plan は何も言わない。

これが「Terraform は state に載っているものしか管理しない」の実体験。03章のドリフト検出(手で変えたコメントが差分に出た)と混同しやすいが、違いは次のとおり。

| 状況 | plan の挙動 |
|---|---|
| **state にあるリソース**を手作業で変更 | ドリフトとして差分に出る(03章) |
| **state にないリソース**を手作業で作成 | 何も出ない。存在しない扱い(本章) |

つまり Terraform 管理下のオブジェクトは守られるが、管理外に作られたものは放置される。「野良リソース」を防ぐ手段は Terraform 自身にはなく、運用ルール(変更は PR 経由のみ)と権限設計(手作業で作れるロールを配らない)で担保する。既存の野良リソースを管理下に入れるのが `terraform import`。

## 5. 後片付け

```sql
DROP DATABASE MANUAL_DB;
```

```bash
terraform destroy -var-file=dev.tfvars
```

destroy の対象一覧に MANUAL_DB が**含まれない**ことも確認できる(state にないものは消しもしない)。
