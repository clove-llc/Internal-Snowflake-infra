# answers/ — 演習の解答

各章のハンズオン・演習の完成形。詰まったときの参照用で、写経ではなく答え合わせに使うこと。

```
answers/
├── 03-first-apply/          # 03章: 最小構成(DB 1つ)
├── 04-warehouse-and-role/   # 04章: DB + スキーマ + WH + ロール + グラント(演習解答は exercise.tf)
├── 05-variables/            # 05章: 04章の変数化 + tfvars + output(演習解答含む)
├── 06-state-management/     # 06章: 演習の期待される出力と解説(コードは 05 を使う)
└── 07-checklist.md          # 07章: チェックリストの解答
```

各ディレクトリは独立して動く。試すときはそのディレクトリで:

```bash
terraform init
terraform plan                          # 05 は -var-file=dev.tfvars を付ける
terraform apply
terraform destroy                       # 確認が済んだら必ず
```

作られるリソースはすべて `TUTORIAL_` / `DEV_TUTORIAL_` プレフィックス。共有アカウントで apply する場合は、演習コードと同様に `TUTORIAL_` を `TUTORIAL_<名前>_` に読み替えること(workspaces/README)。自分の演習環境が残っている場合も名前が衝突するので、先に destroy してから実行する。
