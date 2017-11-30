require 'date'
require 'open-uri'
require 'nokogiri'
require './pool_event.rb'
require './pool_time.rb'

BASE_URL = 'http://www.city.hiratsuka.kanagawa.jp'
POOL_URL = BASE_URL + '/koen/page-c_00812.html'

def get_pdf_link(date)
  html = open(POOL_URL) do |f|
    f.read
  end
  # puts html

  page = Nokogiri::HTML.parse(html, nil, 'UTF-8')
  heisei = date.year - 1988
  keyword = "温水プール予定表" + heisei.to_s + "年" + date.month.to_s + "月"
  # puts keyword
  pdfurl = BASE_URL
  page.xpath("//a[contains(text(), '%s')]" % keyword).each do |a|
    # puts a
    pdfurl = pdfurl +  a[:href]
  end
  if pdfurl == BASE_URL then
    raise "URLリンクが見つかりません。"
  end

  return pdfurl
end

def download_link(pdfurl, pdf_name)
  open(pdfurl) do |file|
    open(pdf_name, "w+b") do |out|
      out.write(file.read)
    end
  end
end


PAGE = 1
ROW = 6
X = 149
Y = 240
W = 680
H = 1011

date = Date.today + ARGV[0].to_i
pdf_name = 'pool.pdf'

pdf_url = get_pdf_link(date)
download_link(pdf_url, pdf_name)
events =  get_events(pdf_name, PAGE, ROW, date.day)
events = events.map{|s| s.sub(/※県水連/,  '水泳指導員養成講習会')}
events = events.map{|s| s.sub(/体協/,    '県体協水泳教室')}
events = events.map{|s| s.sub(/財団/,    '財団水泳教室')}
events = events.map{|s| s.sub(/アクア/,   'アクアビス教室')}
events = events.map{|s| s.sub(/水泳体操/, 'はつらつ水泳体操')}
events = events.map{|s| s.sub(/消防/,    '平塚消防水難訓練')}
status = get_status_list(pdf_name, PAGE, X, Y, W, H, date.day)
status = status.slice(2, status.length - 4)

message = ''
if events.length == 1 && events[0] == '休館日' then
  message = '休館日です。'
else
  if events.length > 0 then
    message += events.join('、') + 'があります。'
  end

  if status.reduce{ | sum, n | sum + n } == 0 then
    message += '利用できる時間はありません。'
  elsif status.find_all{ | n | n == 1 }.length == status.length then
    message += '終日 50M 3コースを利用できます。'
  elsif status.find_all{ | n | n == 2 }.length == status.length then
    message += '終日 50M 2コースを利用できます。'
  elsif status.find_all{ | n | n == 3 }.length == status.length then
    message += '終日 25Mコースを利用できます。'
  else
    message += '平塚市のホームページでスケジュールを確認してください。'
  end
end

puts '{'
puts '  "pool":    ' + '”平塚市総合公園温水プール”' + ','
puts '  "date":    ' + date.strftime('”%Y年%m月%d日”') + ','
puts '  "events":  ' + events.to_s + ','
puts '  "status":  ' + status.to_s + ', '
puts '  "message": ' + sprintf('"%s"', message)
puts '}'
