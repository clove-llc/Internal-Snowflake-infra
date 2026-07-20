# 06. state の管理

ここまで state は手元の `terraform.tfstate`(ローカル state)だった。個人学習はそれでよいが、チームでは成立しない。理由と解決策を押さえる。概念中心の章で、手を動かすのは最後の演習のみ。

## 1. ローカル state の4つの問題

1. **共有できない** — state を持つ人しか正しく plan できない。持っていない人が実行すると「全部新規作成」という誤った計画になる
2. **失ったら管理不能** — マシン故障や誤削除で state が消えると、Terraform は管理対象を忘れる。リソースは残るのに面倒だけが残る
3. **同時実行で壊れる** — 2人が同時に apply すると state が破損しうる
4. **シークレットが平文** — state にはリソース属性がそのまま JSON で入る。**Git へのコミットは厳禁**(本リポジトリは `.gitignore` 済み)

## 2. リモートバックエンド

state の保存先は backend 設定で切り替えられる。クラウドストレージに置き、ロック機構を付けたものがリモートバックエンドで、チーム開発の前提。

| 選択肢 | 向き |
|---|---|
| S3(`use_lockfile = true` でロック) | AWS 利用組織の定番 |
| HCP Terraform(旧 Terraform Cloud) | マネージド。小規模なら無料枠で足りる |
| GCS / Azure Blob | GCP / Azure 利用時の同等品 |

設定は `terraform` ブロックに書き、変更後に `terraform init` を再実行する(既存のローカル state はリモートへの移行を対話で聞かれる)。

```hcl
terraform {
  backend "s3" {
    bucket       = "clove-terraform-state"
    key          = "snowflake/dev/terraform.tfstate"
    region       = "ap-northeast-1"
    use_lockfile = true
  }
}
```

本リポジトリの実環境でどれを使うかは未確定(07章の TODO)。チュートリアルの演習はローカル state のままでよい。

## 3. state を扱うコマンド

state ファイルの直接編集は厳禁。操作は専用コマンドで行う。

```bash
terraform state list                              # 管理中リソースの一覧
terraform state show snowflake_database.tutorial  # 属性の詳細
```

進んだ操作は存在だけ覚えておき、必要になったら引く。

| コマンド | 用途 |
|---|---|
| `terraform import` | 手作業で作られた既存リソースを管理下に取り込む。既存環境の IaC 化で必ず使う |
| `terraform state rm` | リソースを**実体は消さずに**管理から外す |
| `terraform state mv` | リソース名変更時に state 上の対応を付け替える(やらないと削除+再作成の計画になる) |

## 4. 運用ルールへの帰結

03章のドリフト体験と本章の内容から、チーム運用のルールは次に定まる。

1. 環境の変更はすべて PR 経由(コード変更 → plan 結果をレビュー → merge → apply)
2. Snowsight での手作業変更は原則禁止。参照・調査は自由
3. 緊急対応で手作業した場合は、事後に必ずコードと state に反映する(コード追記 + `terraform import`)

## 5. 演習

1. 04〜05章の環境を `terraform apply -var-file=dev.tfvars` で作る
2. `terraform state list` と `terraform state show` で中身を見る
3. Snowsight で `CREATE DATABASE MANUAL_DB;` を実行し、`terraform plan` に**何も出ない**ことを確認する — 「state にないものは関知しない」の実体験
4. `DROP DATABASE MANUAL_DB;` で消し、`terraform destroy -var-file=dev.tfvars` で後片付け

---

前: [05. 変数と出力](05-variables.md) / 次: [07. 実運用への一歩](07-project-structure.md)
