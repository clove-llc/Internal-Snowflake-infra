# 05. 変数と出力

04章までは `TUTORIAL_DB` などの名前をすべて直書きしていた。この章で「同じコードを設定だけ変えて使い回す」道具を揃える。dev / prod の環境分離の土台になる。模範解答は [answers/05-variables](../answers/05-variables/)。

## 1. variable — 入力の宣言

`variables.tf`:

```hcl
variable "env" {
  description = "環境名(dev / prod など)。リソース名のプレフィックスに使う"
  type        = string
}

variable "warehouse_size" {
  description = "ウェアハウスのサイズ"
  type        = string
  default     = "XSMALL"

  validation {
    condition     = contains(["XSMALL", "SMALL", "MEDIUM"], var.warehouse_size)
    error_message = "コスト管理のため MEDIUM 以下にすること。"
  }
}
```

- `type` は `string` / `number` / `bool` のほか `list(string)`、`map(string)` などの複合型が使える
- `default` がない変数は実行時に必ず値を要求される。「指定漏れを事故ではなくエラーにする」ためにあえて default を付けない、という使い方をする(env がその例)
- `validation` は値のガードレール。誤って XLARGE を指定するといった事故を plan の前で止められる

## 2. 変数を使う

参照は `var.名前`。文字列への埋め込みは `"${...}"`。

```hcl
resource "snowflake_database" "tutorial" {
  name    = "${upper(var.env)}_TUTORIAL_DB"
  comment = "Terraform チュートリアル用データベース(${var.env})"
}
```

`upper()` は組み込み関数。[関数一覧](https://developer.hashicorp.com/terraform/language/functions)には文字列・コレクション操作が一通り揃っており、複雑な加工をコードで書く前にまず関数を探すとよい。

## 3. locals — コード内の共通値

繰り返し使う値の置き場。外から変える必要がないものは variable にしない。

```hcl
locals {
  prefix = "${upper(var.env)}_TUTORIAL"
}

resource "snowflake_database" "tutorial" {
  name = "${local.prefix}_DB"
}
```

使い分けの基準は一つ: **外から変えたい値は variable、コード内の整理は locals**。

## 4. tfvars — 値の受け渡し

変数値は `.tfvars` ファイルにまとめ、実行時に指定する。

```hcl
# dev.tfvars
env            = "dev"
warehouse_size = "XSMALL"
```

```bash
terraform plan  -var-file=dev.tfvars
terraform apply -var-file=dev.tfvars
```

`prod.tfvars` を作って値を変えれば同じコードで別環境が作れる。これが変数化の狙い。

注意が2つ。`terraform.tfvars` という名前だけは自動で読み込まれる(明示指定が不要になる反面、意図しない値が混入する事故もある)。またシークレットを tfvars に書いてコミットしてはいけない。シークレットは環境変数 `TF_VAR_変数名` で渡す。

## 5. output — 結果の取り出し

apply 後に「作られたものの情報」を取り出す口。`outputs.tf`:

```hcl
output "database_name" {
  description = "作成されたデータベース名"
  value       = snowflake_database.tutorial.name
}

output "analyst_role_name" {
  description = "分析者ロール名。dbt の profiles.yml などで参照する"
  value       = snowflake_account_role.analyst.name
}
```

```bash
terraform output                  # 一覧
terraform output database_name    # 単体取得。スクリプトや CI からの連携に使う
```

## 6. 演習

1. `dev.tfvars` で apply し、`DEV_TUTORIAL_DB` が作られることを確認する
2. `prod.tfvars`(warehouse_size = "SMALL")を作り、plan の差分を**読むだけ**で dev との違いを説明する
3. `-var="warehouse_size=XLARGE"` を付けて validation がエラーを出すことを確認する

演習2で気づくべきこと: 同じディレクトリで dev → prod と apply し直すと、環境が2つできるのではなく **dev が prod に置き換わる**。state が1つしかないため。「1 state = 1環境」が原則で、環境を並存させるにはディレクトリ(= state)ごと分ける。実環境の構成(07章)はこの原則の上に立っている。

後片付け:

```bash
terraform destroy -var-file=dev.tfvars
```

---

前: [04. ウェアハウスとロール](04-warehouse-and-role.md) / 次: [06. state の管理](06-state-management.md)
