# docs/05 演習2の解答。plan の差分は「リソース名のプレフィックスが PROD_ に変わり、WH サイズが SMALL になる」
# ただし同一ディレクトリ(= 同一 state)で apply すると dev が prod に置き換わる点に注意(docs/05 参照)
env            = "prod"
warehouse_size = "SMALL"
