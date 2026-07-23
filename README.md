# Internal-Snowflake-infra

clove の Snowflake 環境を Terraform で管理するリポジトリ。あわせて、Terraform 未経験のメンバーが実環境と同じ題材で IaC を習得するためのチュートリアルを備える。

## 構成

```
├── tutorial/            # チュートリアル
│   ├── docs/            #   本編(00〜07)と用語集
│   ├── answers/         #   演習の解答(そのまま apply 可能)
│   └── workspaces/      #   演習の作業場所。workspaces/<名前>/ で作業し PR を出す
└── sandbox/             # 検証環境
    ├── snowflake/       #   Snowflake 検証アカウント(WFJVSLU-VT27190)の資材
    └── aws/             #   AWS 資材(tfstate 用 S3 バケットなど)
```

## チュートリアル

tutorial/docs/ を番号順に進める。00・02・07 は読み物、03〜06 は演習あり。全体で1日あれば完走できる分量。

| 章 | 内容 |
|---|---|
| [00](tutorial/docs/00-introduction.md) | IaC の動機と Terraform の位置づけ |
| [01](tutorial/docs/01-setup.md) | Terraform インストール、Snowflake キーペア認証 |
| [02](tutorial/docs/02-terraform-basics.md) | HCL / provider / resource / state |
| [03](tutorial/docs/03-first-apply.md) | init → plan → apply → destroy を一周する |
| [04](tutorial/docs/04-warehouse-and-role.md) | ウェアハウス・ロール・グラント、リソース間参照 |
| [05](tutorial/docs/05-variables.md) | variable / tfvars / locals / output |
| [06](tutorial/docs/06-state-management.md) | state の共有とリモートバックエンド |
| [07](tutorial/docs/07-project-structure.md) | 実環境の構成方針・命名規則・変更フロー |

演習コードは `tutorial/workspaces/<名前>/` に書く。詰まったら `tutorial/answers/` と [用語集](tutorial/docs/glossary.md)。

前提: Snowflake アカウント(各自のトライアル。docs/01)、ターミナルと Git の基本操作。Terraform の知識は不要。

## 演習時の注意

- 演習は各自のトライアルアカウントで行う。作成するリソースは `TUTORIAL_` プレフィックスで統一する([workspaces/README](tutorial/workspaces/README.md))
- ウェアハウスは XSMALL・auto_suspend 60秒で作るため費用はほぼかからないが、演習後は必ず `terraform destroy` する

## Snowflake ユーザーの追加

作業は `sandbox/snowflake` で行う。YAML を2ファイル編集して apply するだけ(運用の詳細は [sandbox/snowflake/README](sandbox/snowflake/README.md))。

### 1. users.yaml にエントリを追加

付与したい default_role の段落に追加する。`name` 以外は省略可。

```yaml
ACCOUNTADMIN:
  - name: YAMADA.TARO
    display_name: YAMADA.TARO
    email: YAMADA.TARO@CLOVE-LLC.COM
    default_warehouse: COMPUTE_WH
```

### 2. grants_role.yaml に付与を追加

同じロールの段落にユーザー名を追加する。default_role に対応する付与は必須で、忘れると plan がエラーで止まる。

```yaml
ACCOUNTADMIN:
  - YAMADA.TARO
```

### 3. plan → apply

```bash
cd sandbox/snowflake
terraform plan    # 追加が「ユーザー 1 + ロール付与 1」だけであることを確認
terraform apply
```

チーム運用ではブランチを切り、plan 結果を貼った PR でレビューを受けてから apply する。

### 4. 初期認証情報の設定(Terraform 管理外・手動)

パスワード・公開鍵は Terraform で扱わないため、apply 後に設定する。

```sql
-- パスワードでログインさせる場合(初回ログイン時に変更を強制)
ALTER USER "YAMADA.TARO" SET PASSWORD = '<初期パスワード>' MUST_CHANGE_PASSWORD = TRUE;
```

キーペア認証を使う場合は、本人が公開鍵を生成して登録する([tutorial/docs/01](tutorial/docs/01-setup.md) の手順3)。

変更(段落間の移動 = default_role 変更)や削除(エントリを消す = DROP / REVOKE)も同じ2ファイルで行う。削除は plan の確認を必須とする。

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
