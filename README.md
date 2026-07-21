# Internal-Snowflake-infra

clove の Snowflake 環境を Terraform で管理するリポジトリ。あわせて、Terraform 未経験のメンバーが実環境と同じ題材で IaC を習得するためのチュートリアルを備える。

## 構成

```
├── docs/        # チュートリアル本編(00〜07)と用語集
├── tutorial/    # 演習の作業場所。README 以外は git 管理外
├── answers/     # 演習の解答(そのまま apply 可能)
└── environments/, modules/   # 実環境の資材(今後整備。方針は docs/07)
```

## チュートリアル

docs/ を番号順に進める。00・02・07 は読み物、03〜06 は演習あり。全体で1日あれば完走できる分量。

| 章 | 内容 |
|---|---|
| [00](docs/00-introduction.md) | IaC の動機と Terraform の位置づけ |
| [01](docs/01-setup.md) | Terraform インストール、Snowflake キーペア認証 |
| [02](docs/02-terraform-basics.md) | HCL / provider / resource / state |
| [03](docs/03-first-apply.md) | init → plan → apply → destroy を一周する |
| [04](docs/04-warehouse-and-role.md) | ウェアハウス・ロール・グラント、リソース間参照 |
| [05](docs/05-variables.md) | variable / tfvars / locals / output |
| [06](docs/06-state-management.md) | state の共有とリモートバックエンド |
| [07](docs/07-project-structure.md) | 実環境の構成方針・命名規則・変更フロー |

演習コードは `tutorial/` に書く。詰まったら `answers/` と [用語集](docs/glossary.md)。

前提: Snowflake アカウント(個人のトライアルで可)、ターミナルと Git の基本操作。Terraform の知識は不要。

## 演習時の注意

- 作成するリソースは `TUTORIAL_` プレフィックスで統一し、実環境と区別する
- ウェアハウスは XSMALL・auto_suspend 60秒で作るため費用はほぼかからないが、演習後は必ず `terraform destroy` する

## 公式ドキュメント

### Terraform

| リンク | 内容 | 関連章 |
|---|---|---|
| [インストール](https://developer.hashicorp.com/terraform/install) | 各 OS へのインストール手順 | 01 |
| [言語リファレンス](https://developer.hashicorp.com/terraform/language) | HCL の文法、ブロック、式の全仕様 | 02 |
| [CLI コマンド](https://developer.hashicorp.com/terraform/cli/commands) | init / plan / apply ほか全コマンドの仕様 | 03 |
| [変数と出力](https://developer.hashicorp.com/terraform/language/values/variables) | variable の型・validation・値の優先順位 | 05 |
| [組み込み関数](https://developer.hashicorp.com/terraform/language/functions) | upper() など全関数の一覧 | 05 |
| [state](https://developer.hashicorp.com/terraform/language/state) | state の仕組みと取り扱い | 06 |
| [backend](https://developer.hashicorp.com/terraform/language/backend) | state の保存先設定(S3 ほか) | 06 |
| [モジュール](https://developer.hashicorp.com/terraform/language/modules) | module の作り方と呼び出し方 | 07 |
| [スタイルガイド](https://developer.hashicorp.com/terraform/language/style) | 命名・ファイル分割などの公式規約 | 全般 |

### Snowflake provider

| リンク | 内容 | 関連章 |
|---|---|---|
| [provider ドキュメント](https://registry.terraform.io/providers/snowflakedb/snowflake/latest/docs) | 認証設定と全リソースのリファレンス | 01〜 |
| [grant_privileges_to_account_role](https://registry.terraform.io/providers/snowflakedb/snowflake/latest/docs/resources/grant_privileges_to_account_role) | グラント定義の全パターン | 04 |
| [GitHub リポジトリ](https://github.com/snowflakedb/terraform-provider-snowflake) | リリースノート、既知の issue、移行ガイド | 全般 |

### Snowflake

| リンク | 内容 | 関連章 |
|---|---|---|
| [キーペア認証](https://docs.snowflake.com/en/user-guide/key-pair-auth) | 鍵生成から登録までの正式手順 | 01 |
| [アカウント識別子](https://docs.snowflake.com/en/user-guide/admin-account-identifier) | organization / account name の確認方法 | 01 |
| [ウェアハウス](https://docs.snowflake.com/en/user-guide/warehouses) | サイズ・課金・auto suspend の仕様 | 04 |
| [アクセス制御の概要](https://docs.snowflake.com/en/user-guide/security-access-control-overview) | ロール・権限モデルの全体像 | 04 |
| [GRANT &lt;privileges&gt;](https://docs.snowflake.com/en/sql-reference/sql/grant-privilege) | 付与できる権限の一覧(SQL リファレンス) | 04 |
| [Terraforming Snowflake](https://quickstarts.snowflake.com/guide/terraforming_snowflake/index.html) | Snowflake 公式の Terraform クイックスタート | 全般 |
