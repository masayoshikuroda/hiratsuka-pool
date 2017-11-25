require 'date'
require 'open-uri'
require 'nokogiri'
require 'pdftotext'

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
# 予定表を文字列で取得
#
pages = Pdftotext.pages(pdf_name)
text = pages.first.text
#puts text
lines = text.split(/\r?\n/).slice(6, 31)
#puts lines[0]
#puts lines[30]

#
# 予定表から指定日のイベントを抽出
#
line = lines.find{|l| l.include?(filter)}
#puts line
fields = line.split(filter)
field = fields[1].lstrip
#p field
event = field.slice(1, field.length - 2).strip
puts event
