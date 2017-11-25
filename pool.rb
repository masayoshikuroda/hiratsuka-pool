require 'date'
require 'open-uri'
require 'nokogiri'

#
# 調べる日付を取得
#
date = Date.today
if ARGV.length > 0 then
  date = date + ARGV[0].to_i
end
heisei = date.year - 1988
#print(date.year, "年", date.month, "月", date.day, "日")

#
# 平塚温水プールのページを取得
#
baseurl= 'http://www.city.hiratsuka.kanagawa.jp'
poolurl = baseurl + '/koen/page-c_00812.html'
charset = 'UTF-8'
html = open(poolurl) do |f|
#  charset = f.charset
  f.read
end
#puts charset

#
# PDF へのリンクをパース
#
page = Nokogiri::HTML.parse(html, nil, charset)
keyword = "温水プール予定表" + heisei.to_s + "年" + date.month.to_s + "月"
#puts keyword
pdfurl = baseurl
page.xpath("//a[contains(text(), '%s')]" % keyword).each do |a|
  #puts a
  pdfurl = pdfurl +  a[:href]
end
if pdfurl == baseurl then
  raise "URLリンクが見つかりません。"
end
#puts pdfurl

#
# PDFをダウンロード
#
pdf_name = 'pool.pdf'
open(pdfurl) do |file|
  open(pdf_name, "w+b") do |out|
    out.write(file.read)
  end
end


#
# PDF中の日付キーワードを作成
#
day = date.day
filter = day.to_s.tr('0-9', '０-９') + '日'
filter = " " + filter if (day < 10)
#puts filter

#
# PDF中から指定日付の予定を抽出
#
exec("sh", "pool.sh", pdf_name, filter)
