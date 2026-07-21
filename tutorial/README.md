# tutorial/ — 演習の作業場所

演習コードは `tutorial/<GitHub ユーザー名>/` に書く(例: `tutorial/benjamin0313cl/`)。書き始めは [docs/03](../docs/03-first-apply.md) から。

## ルール

- **リソース名に自分の名前を入れる。** 共有アカウントのため、docs のコード例にある `TUTORIAL_` は `TUTORIAL_<名前>_` に読み替える(例: `TUTORIAL_TARO_DB`)。付け忘れると他の受講者と衝突する
- **章の演習を終えたら PR を出す。** ブランチを切り、`terraform plan` の結果を PR に貼ってレビューを受ける。07章の変更フローの練習を兼ねる
- **state はコミットされない**(`.gitignore` 済み)。ローカルで保持し、失くさないこと
- **終わったら destroy。** 各章の演習後、および全章完了時に `terraform destroy` でリソースを消す
