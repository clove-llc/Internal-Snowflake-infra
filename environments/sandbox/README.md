# environments/sandbox — 検証環境

チュートリアル演習で使う共有サンドボックスアカウントの資材。管理者が運用する。

## 管理対象

- `TUTORIAL_LEARNER` ロール — 受講者用。アカウントレベルの `CREATE DATABASE` / `CREATE WAREHOUSE` / `CREATE ROLE` を持つ。受講者は自分で作ったオブジェクトの所有者になるため、演習内のグラント操作はこれだけで完結する

## 適用手順(管理者)

接続情報を環境変数で設定し(`SNOWFLAKE_ROLE=ACCOUNTADMIN`)、このディレクトリで:

```bash
terraform init
terraform plan
terraform apply
```

## 受講者の払い出し(当面は手動)

```sql
CREATE USER <名前> DEFAULT_ROLE = TUTORIAL_LEARNER;
GRANT ROLE TUTORIAL_LEARNER TO USER <名前>;
```

公開鍵の登録(`ALTER USER ... SET RSA_PUBLIC_KEY`)は受講者が自分で行う(tutorial/docs/01)。受講者ユーザーの tf 化は TODO。

## state

当面ローカル(管理者1名運用のため)。`*.tfstate` は git 管理外なので、リモートバックエンド移行までは state ファイルの保管に注意する。
