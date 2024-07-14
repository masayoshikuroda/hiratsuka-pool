# pool

平塚総合体育館の温水プールの予定を取得するスクリプト。

- 予定は平塚市のホームページにある予定表（PDF）から取得


## ライブラリ
```
$ sudo apt-get install poppler-utils
$ sudo apt-get install ruby
$ sudo apt-get install ruby-dev
$ sudo gem install nokogiri
$ sudo gem install pdftotext
$ sudo gem install cliver

```

## 実行例
```
$ ruby pool.rb
体協
$ ruby pool 1
休館日
$
```

### PDF取得
```
$ ruby -r./pool_pdf -e "PoolPdf.new(Date.today + 1)"
$ ls -l pool.pdf
pool.pdf
$
```

### スケジュール取得
```
$ ruby -r./pool_time -e "p PoolTime::get_schedule(PoolTime.new('pool.pdf', 12).get_status_list(1))"
[[2, 9.5, 12.5], [1, 12.5, 20.5]]
$
```
