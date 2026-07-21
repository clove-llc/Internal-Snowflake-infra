# 03. はじめての apply

Snowflake にデータベースを1つ作り、変更し、壊す。サイクルを一周して plan の読み方まで身につけるのがこの章のゴール。

作業場所は `tutorial/workspaces/<自分の名前>/`([workspaces/README](../workspaces/README.md) のルールを先に読む)。共有アカウントのため、以降のコード例の `TUTORIAL_` は `TUTORIAL_<名前>_` に読み替えること。解答は [answers/03-first-apply](../answers/03-first-apply/)。

## 1. main.tf を書く

```hcl
terraform {
  required_version = ">= 1.5"
  required_providers {
    snowflake = {
      source  = "snowflakedb/snowflake"
      version = "2.18.0"
    }
  }
}

provider "snowflake" {
  # 接続情報は環境変数 SNOWFLAKE_* から読む
}

resource "snowflake_database" "tutorial" {
  name    = "TUTORIAL_DB"
  comment = "Terraform チュートリアル用データベース"
}
```

## 2. init

```bash
terraform init
```

`Terraform has been successfully initialized!` で成功。このとき2つ生成される。

- `.terraform/` — provider 本体。コミットしない
- `.terraform.lock.hcl` — provider バージョンのロックファイル。チーム全員を同じバージョンに揃えるため**コミットする**

## 3. plan — 実行計画を読む

```bash
terraform plan
```

```
  # snowflake_database.tutorial will be created
  + resource "snowflake_database" "tutorial" {
      + name    = "TUTORIAL_DB"
      ...

Plan: 1 to add, 0 to change, 0 to destroy.
```

読み方は3つ覚えれば足りる: 行頭の `+` が作成、`~` が変更、`-` が削除。最終行の `Plan:` がサマリ。**この時点で Snowflake には何も起きていない。** plan はシミュレーションで、接続確認を兼ねる(エラーが出たら01章のトラブルシューティングへ)。

## 4. apply

```bash
terraform apply
```

plan と同じ計画が出た後に確認を求められる。`yes` で実行。

```
snowflake_database.tutorial: Creation complete after 1s
Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

Snowsight で TUTORIAL_DB ができていることを確認。手元には `terraform.tfstate` が生成されており、覗くと作成したリソースの属性が JSON で入っている。直接編集は厳禁(操作は06章のコマンド経由で行う)。

## 5. 変更 — 差分検出を見る

`comment` を書き換えて再度 plan すると、今度は `~`(変更)として出る。

```
  ~ comment = "Terraform チュートリアル用データベース" -> "..."
Plan: 0 to add, 1 to change, 0 to destroy.
```

apply して反映。あるべき姿を書き換え、差分を確認し、適用する——変更作業はこれがすべてで、新規作成と手順が変わらない点が手作業との決定的な違い。

## 6. ドリフト — 手作業がどう扱われるか

Terraform を通さず Snowsight から変更してみる。

```sql
ALTER DATABASE TUTORIAL_DB SET COMMENT = '手で書き換えた';
```

この状態で `terraform plan` を打つと、実環境を読み直して「コードとずれている」という差分(ドリフト)が出る。apply すれば**コードの内容に戻される**。コードが唯一の正であり、手作業は次の apply で消える。「環境の変更は必ずコードで」という運用ルール(06章)はこの仕組みの帰結。

## 7. destroy — 後片付け

```bash
terraform destroy
```

削除計画が出て、`yes` で全リソースが消える。各章の演習の最後に必ず実行する。

## 補助コマンド

書き味を上げる2つ。以降は習慣にする。

```bash
terraform fmt        # インデント等を規約どおりに自動整形
terraform validate   # apply せずに構文・参照の妥当性を検査
```

---

前: [02. Terraform の基本概念](02-terraform-basics.md) / 次: [04. ウェアハウスとロール](04-warehouse-and-role.md)
