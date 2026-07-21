# workspaces/ — 演習の作業場所

演習コードは `workspaces/<GitHub ユーザー名>/` に書く(例: `workspaces/benjamin0313cl/`)。書き始めは [docs/03](../docs/03-first-apply.md) から。

## ルール

- **演習は各自のトライアルアカウントで行う**(docs/01)。リソース名は docs のコード例どおり `TUTORIAL_` プレフィックス
- **章の演習を終えたら PR を出す。** ブランチを切り、`terraform plan` の結果を PR に貼ってレビューを受ける。07章の変更フローの練習を兼ねる
- **state はコミットされない**(`.gitignore` 済み)。ローカルで保持し、失くさないこと
- **終わったら destroy。** 各章の演習後、および全章完了時に `terraform destroy` でリソースを消す
