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

docs/ を番号順に進める。00・02・06・07 は読み物、03〜05 が手を動かす章。全体で1日あれば完走できる分量。

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
