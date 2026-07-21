# 07. 実運用の構成方針

チュートリアルの内容を実環境の管理につなげる。この章は現時点では方針の宣言で、実資材の整備に伴い更新する。

## ディレクトリ構成

```
.
├── tutorial/
│   ├── docs/
│   ├── answers/             # 演習の解答
│   └── workspaces/          # 演習の作業場所(workspaces/<名前>/ 単位で PR)
├── modules/                 # 再利用部品(社内標準が固まってから)
│   └── database-with-roles/
└── environments/            # 環境ごとのエントリポイント。1環境 = 1ディレクトリ = 1 state
    ├── sandbox/             # 検証環境。演習用ロールを管理(整備済み)
    ├── dev/
    │   ├── main.tf
    │   ├── backend.tf       # 環境ごとに独立した state
    │   └── terraform.tfvars
    └── prod/
```

方針は2つ。

- **環境はディレクトリで分離する。** 05章で見たとおり 1 state = 1環境。tfvars の切り替えだけで dev / prod を出し分ける構成は、apply 先を取り違える事故と隣り合わせになるため採らない
- **モジュール化は急がない。** module は「resource の集まりに変数を付けて部品化したもの」で、`module "raw_db" { source = "../../modules/database-with-roles" ... }` のように呼び出す。強力だが、標準が固まる前に作ると抽象化が外れる。当面は resource を素直に並べる

## 命名規則

| 対象 | 規則 | 例 |
|---|---|---|
| Snowflake リソース | `UPPER_SNAKE_CASE` + 環境プレフィックス | `DEV_RAW_DB`, `PROD_ANALYST` |
| Terraform リソース名 | `lower_snake_case`、環境名を含めない | `snowflake_database.raw` |
| ファイル | 役割ベース | `database.tf`, `roles.tf` |

Terraform リソース名に環境名を入れないのは、同じコードを dev / prod で共有し、環境差は変数で吸収するため。

## 権限設計の方針

実運用では最上位ロールを常用しない。

- Terraform 実行は専用サービスユーザー(キーペア認証)に分離する
- オブジェクト作成(DB・WH)は SYSADMIN 系、ロール・グラント管理は SECURITYADMIN 系に分担する
- 人に付与するロールは「機能ロール(analyst, engineer)× アクセスロール(DB 単位の read / write)」の2階層で設計する

詳細設計は実資材の整備時に運用ドキュメントとして docs/ に追加する。

## 変更フロー

1. ブランチを切りコードを変更
2. plan 結果を PR に貼りレビューを受ける(将来 CI で自動化)
3. merge 後に apply(将来 CI/CD から実行)
4. Snowsight での手作業変更は原則禁止(06章)

## チェックリスト

答え合わせは [answers/07-checklist.md](../answers/07-checklist.md)。

- [ ] init / plan / apply / destroy を説明しながら実行できる
- [ ] plan の `+` / `~` / `-` と `(known after apply)` を読める
- [ ] リソース間参照を使って複数リソースを定義できる
- [ ] variable / locals / output を使い分けられる
- [ ] state の役割と、リモートバックエンドが必要な理由を説明できる
- [ ] 「変更は必ず PR 経由」の理由を説明できる

## リポジトリの TODO

- [ ] 受講者ユーザー払い出しの tf 化(environments/sandbox。現状は手動 SQL)
- [ ] リモートバックエンドの選定・設定
- [ ] Terraform 用サービスユーザーの作成と権限設計ドキュメント
- [ ] `environments/dev` の実資材作成
- [ ] CI(PR で自動 plan)の整備

---

前: [06. state の管理](06-state-management.md) / [README](../README.md)
