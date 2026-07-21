# 01. 環境構築

ゴール: 手元のマシンから Terraform で Snowflake に接続できる状態を作る。

## 1. Terraform のインストール

```bash
brew install terraform
terraform version   # v1.x が表示されればよい
```

リポジトリ直下の `.terraform-version` が動作確認済みバージョン(1.12.2)。`tfenv` 利用者は自動でこのバージョンに揃う。brew の最新版でも動く想定だが、挙動が合わないときはここに揃えること。

## 2. Snowflake アカウント

演習は共有サンドボックスアカウントで行う。管理者から次の3点を受け取る。

1. **アカウント識別子** — `MYORG-XY12345` の形式。前半が organization name、後半が account name(Snowsight 左下のアカウントメニュー → Account からも確認できる)
2. **ユーザー名** — 演習用ロール `TUTORIAL_LEARNER`(environments/sandbox で管理)が付与済みのもの

個人で完結して試したい場合は https://signup.snowflake.com/ のトライアル(30日無料、カード不要)でも全章そのまま実施できる。その場合ロールは `ACCOUNTADMIN` を使い、リソース名の読み替え(workspaces/README)は不要。

## 3. キーペア認証の設定

プログラムからの接続はパスワードではなくキーペア認証(RSA 公開鍵・秘密鍵)を使う。Snowflake はプログラムアクセスのパスワード認証を段階的に廃止しており、最初からキーペアで覚えるのが早道。

鍵ペアの生成(PKCS#8・暗号化なし):

```bash
mkdir -p ~/.snowflake && cd ~/.snowflake
openssl genrsa 2048 | openssl pkcs8 -topk8 -inform PEM -out tutorial_rsa_key.p8 -nocrypt
openssl rsa -in tutorial_rsa_key.p8 -pubout -out tutorial_rsa_key.pub
chmod 600 tutorial_rsa_key.p8
```

公開鍵をユーザーに登録する。`cat tutorial_rsa_key.pub` の出力から `-----BEGIN/END PUBLIC KEY-----` の行を**除いた**中身を使い、Snowsight のワークシートで実行(改行は含まれていてよい):

```sql
ALTER USER <ユーザー名> SET RSA_PUBLIC_KEY='MIIBIjANBgkqh...';

-- 確認: RSA_PUBLIC_KEY_FP に値が入っていれば登録済み
DESC USER <ユーザー名>;
```

自分自身の公開鍵は自分で設定できる。権限エラーになる場合は管理者に登録を依頼する。

## 4. 接続情報を環境変数で渡す

Snowflake provider は `SNOWFLAKE_*` 環境変数を自動で読む。認証情報をコードに書かないため、この方式で統一する。`~/.zshrc` に追記:

```bash
export SNOWFLAKE_ORGANIZATION_NAME="MYORG"       # アカウント識別子の前半
export SNOWFLAKE_ACCOUNT_NAME="XY12345"          # アカウント識別子の後半
export SNOWFLAKE_USER="<ユーザー名>"
export SNOWFLAKE_AUTHENTICATOR="SNOWFLAKE_JWT"   # キーペア認証の指定
export SNOWFLAKE_PRIVATE_KEY="$(cat $HOME/.snowflake/tutorial_rsa_key.p8)"
export SNOWFLAKE_ROLE="TUTORIAL_LEARNER"         # トライアルの場合は ACCOUNTADMIN
```

秘密鍵は**ファイルパスではなく中身**を渡す(`SNOWFLAKE_PRIVATE_KEY_FILE` という変数は存在しない)。`$(cat ...)` で読み込むのはそのため。

## トラブルシューティング

| 症状 | 原因の当たり |
|---|---|
| `JWT token is invalid` (390144) | 公開鍵が未登録・別ユーザーに登録した・`SNOWFLAKE_USER` の綴り違い |
| 接続先が見つからない / タイムアウト | アカウント識別子の分割ミス。`ORGANIZATION_NAME` と `ACCOUNT_NAME` を再確認 |
| 秘密鍵のパースエラー | 鍵が PKCS#8 でない。生成コマンドの `pkcs8 -topk8` を確認 |

## チェックリスト

- [ ] `terraform version` が表示される
- [ ] アカウント識別子と、TUTORIAL_LEARNER 付与済みのユーザー名を受け取った
- [ ] `DESC USER` で `RSA_PUBLIC_KEY_FP` に値が入っている
- [ ] 環境変数6つを設定した(`echo $SNOWFLAKE_ACCOUNT_NAME` などで確認)

接続の実地確認は03章の `terraform plan` が兼ねる。

---

前: [00. はじめに](00-introduction.md) / 次: [02. Terraform の基本概念](02-terraform-basics.md)
