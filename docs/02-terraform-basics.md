# 02. Terraform の基本概念

登場人物は4つ: HCL、resource、provider、state。読むだけの章だが、特に state は以降の全章に効いてくる。

```
┌───────────────┐      ┌───────────────┐      ┌──────────────┐
│ .tf ファイル    │      │  Terraform     │      │  Snowflake    │
│ (あるべき姿)    │ ───▶ │  + provider    │ ───▶ │  (実環境)      │
└───────────────┘      └───────┬───────┘      └──────────────┘
                               │
                       ┌───────▼───────┐
                       │ state ファイル  │
                       │ (把握している現状)│
                       └───────────────┘
```

## HCL — 設定を書く言語

Terraform のコードは HCL で書き、拡張子は `.tf`。プログラミング言語というより構造化された設定ファイルで、実体はブロックの積み重ね。

```hcl
ブロック種別 "ラベル" "ラベル" {
  引数 = 値
}
```

## resource — 管理対象の宣言

主役のブロック。「TUTORIAL_DB という名前のデータベース」はこう書く。

```hcl
resource "snowflake_database" "tutorial" {
  name    = "TUTORIAL_DB"
  comment = "Terraform チュートリアル用"
}
```

- `snowflake_database` はリソースタイプ。何が指定できるかはタイプごとに [provider ドキュメント](https://registry.terraform.io/providers/snowflakedb/snowflake/latest/docs)にある
- `tutorial` は**コード内での名前**。Snowflake 上の名前(`name = ...`)とは別物で、他の場所から `snowflake_database.tutorial` として参照するために使う(04章)

## provider — サービスへの接続口

どのサービスをどのバージョンのプラグインで操作するかの宣言。

```hcl
terraform {
  required_version = ">= 1.5"
  required_providers {
    snowflake = {
      source  = "snowflakedb/snowflake"
      version = "2.18.0"    # 完全固定
    }
  }
}

provider "snowflake" {
  # 接続情報は環境変数 SNOWFLAKE_* から読まれるため書かない
}
```

バージョン指定を省略すると常に最新が使われ、provider の破壊的変更で「昨日まで動いたコードが今日壊れる」が起きる。`~> 2.0`(2.x の範囲で最新)のような範囲指定もできるが、本リポジトリは全員が同じ挙動になることを優先して完全固定にしている。バージョンを上げるときは、この値の変更を PR にしてレビューを通す。

## state — Terraform が把握している現状

Terraform は自分が作ったリソースの一覧と属性を state ファイル(`terraform.tfstate`)に記録し、実行のたびに3者を突き合わせる。

| | 役割 |
|---|---|
| `.tf` | あるべき姿 |
| state | Terraform が把握している現状 |
| Snowflake | 本当の現状 |

差分の解釈はこうなる: `.tf` にあって state にないものは**作成**、両方にあって設定が違うものは**変更**、state にあって `.tf` にないものは**削除**。

ここから Terraform の最重要の性質が出てくる。

> **Terraform は state に載っているものしか管理しない。**
> Snowsight で手作業で作ったリソースは存在しないものとして扱われる。逆に state を失えば、Terraform は自分が何を作ったかを忘れる。

state の共有と保護は実運用の主要トピックで、06章で扱う。

## 基本サイクル

操作はほぼこの3つの繰り返し。

| コマンド | やること |
|---|---|
| `terraform init` | provider の取得など作業ディレクトリの初期化。最初と構成変更時のみ |
| `terraform plan` | 差分計算と実行計画の表示。**環境には触らない** |
| `terraform apply` | 計画の適用。実環境が変わるのはここだけ |

plan で差分を読み、納得してから apply する。この習慣が Terraform の安全性のほぼすべて。

---

前: [01. 環境構築](01-setup.md) / 次: [03. はじめての apply](03-first-apply.md)
