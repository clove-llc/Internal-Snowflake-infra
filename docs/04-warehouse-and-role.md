# 04. ウェアハウスとロール

Snowflake 環境の基本セット(DB + スキーマ + ウェアハウス + ロール + グラント)を組み立てる。新しく学ぶのはリソース間の参照とファイル分割。解答は [answers/04-warehouse-and-role](../answers/04-warehouse-and-role/)。

## 1. ファイル分割のルール

Terraform は同一ディレクトリの `.tf` を**すべて連結して1つの設定として扱う**。ファイル名に意味はなく、分割は純粋に人間の読みやすさのため。03章の続きを次の構成に組み替える。

```
tutorial/
├── main.tf        # terraform / provider ブロックのみ
├── database.tf
├── warehouse.tf
└── roles.tf
```

## 2. database.tf — リソース間参照

```hcl
resource "snowflake_database" "tutorial" {
  name    = "TUTORIAL_DB"
  comment = "Terraform チュートリアル用データベース"
}

resource "snowflake_schema" "raw" {
  database = snowflake_database.tutorial.name   # ← 参照
  name     = "RAW"
  comment  = "生データ置き場"
}
```

`database = "TUTORIAL_DB"` と直書きせず、リソースの属性を参照している。効果は2つ。

1. DB 名を変えても参照側に自動で波及する(直書きだと壊れる)
2. 「DB を作ってからスキーマ」という依存順序を Terraform が参照から自動で導く。作成順を自分で管理する必要はない

## 3. warehouse.tf — コスト設定込みで

```hcl
resource "snowflake_warehouse" "tutorial" {
  name           = "TUTORIAL_WH"
  comment        = "Terraform チュートリアル用ウェアハウス"
  warehouse_size = "XSMALL"

  auto_suspend        = 60     # 60秒アイドルで停止
  auto_resume         = true   # クエリが来たら自動再開
  initially_suspended = true   # 作成直後は停止状態
}
```

Snowflake の課金の大半はウェアハウスの稼働時間(XSMALL で 1 クレジット/時)。`auto_suspend` を短く + `initially_suspended = true` が定石で、この3行を欠いた WH 定義はレビューで指摘対象と思ってよい。

## 4. roles.tf — グラントの3段構造

「TUTORIAL_DB を読める分析者ロール」を作る。Snowflake で「データを読む」には DB への USAGE、スキーマへの USAGE、テーブルへの SELECT の**3段階すべて**が必要——ここが Snowflake 権限設計の核心で、1段でも欠けるとオブジェクトが見えない。

```hcl
resource "snowflake_account_role" "analyst" {
  name    = "TUTORIAL_ANALYST"
  comment = "チュートリアル用: 分析者ロール"
}

# 1段目: DB への USAGE
resource "snowflake_grant_privileges_to_account_role" "analyst_db" {
  account_role_name = snowflake_account_role.analyst.name
  privileges        = ["USAGE"]
  on_account_object {
    object_type = "DATABASE"
    object_name = snowflake_database.tutorial.name
  }
}

# ウェアハウスへの USAGE(クエリ実行に必要)
resource "snowflake_grant_privileges_to_account_role" "analyst_wh" {
  account_role_name = snowflake_account_role.analyst.name
  privileges        = ["USAGE"]
  on_account_object {
    object_type = "WAREHOUSE"
    object_name = snowflake_warehouse.tutorial.name
  }
}

# 2段目: スキーマへの USAGE
resource "snowflake_grant_privileges_to_account_role" "analyst_schema" {
  account_role_name = snowflake_account_role.analyst.name
  privileges        = ["USAGE"]
  on_schema {
    schema_name = "\"${snowflake_database.tutorial.name}\".\"${snowflake_schema.raw.name}\""
  }
}

# 3段目: スキーマ内の全テーブルへの SELECT(future = 今後作られる分も)
resource "snowflake_grant_privileges_to_account_role" "analyst_tables" {
  account_role_name = snowflake_account_role.analyst.name
  privileges        = ["SELECT"]
  on_schema_object {
    future {
      object_type_plural = "TABLES"
      in_schema          = "\"${snowflake_database.tutorial.name}\".\"${snowflake_schema.raw.name}\""
    }
  }
}
```

補足:

- `future` は「今後このスキーマに作られるテーブルにも自動で SELECT を付与する」設定。テーブルが増えるたびに GRANT を書き足さずに済むので実運用ではほぼ必須
- `"\"...\""` のエスケープは `DB名.スキーマ名` を完全修飾名として渡すための記法。グラント系リソースは provider の中でも書き味に癖がある部分なので、書けなくても[ドキュメント](https://registry.terraform.io/providers/snowflakedb/snowflake/latest/docs/resources/grant_privileges_to_account_role)を引けば十分

## 5. plan を読んでから apply

`terraform plan` で `Plan: 7 to add` になるはず(DB 1 + スキーマ 1 + WH 1 + ロール 1 + グラント 4 − 数えて合うか確認)。出力中の `(known after apply)` は「apply するまで確定しない値」の印で、参照でつながったリソースに現れる。

apply 後、Snowsight で確認:

```sql
SHOW GRANTS TO ROLE TUTORIAL_ANALYST;
```

## 6. 演習

コードだけで実現すること。解答は [answers/04-warehouse-and-role/exercise.tf](../answers/04-warehouse-and-role/exercise.tf)。

1. `MART` スキーマを追加し、TUTORIAL_ANALYST に RAW と同等の権限(スキーマ USAGE + future TABLES への SELECT)を付与する
2. `TUTORIAL_ENGINEER` ロールを追加し、TUTORIAL_DB への `USAGE` と `CREATE SCHEMA` を付与する

終わったら `terraform destroy`。

---

前: [03. はじめての apply](03-first-apply.md) / 次: [05. 変数と出力](05-variables.md)
