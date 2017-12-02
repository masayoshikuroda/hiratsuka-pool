require 'date'
require 'open-uri'
require 'nokogiri'
require_relative 'pool_event.rb'
require_relative 'pool_time.rb'

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

def to_jikoku(val)
	hm = val.to_s.split(".")
  jikoku = hm[0] + "時"
  jikoku += hm[1] == "0" ? "" : "30分"
  return jikoku
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
schedule = get_schedule(status)

message = ''
if events.length == 1 && events[0] == '休館日' then
  message = '休館日です。'
else
  if events.length > 0 then
    message += events.join('、') + 'があります。'
  end

  if schedule.length == 0 then
    message += '利用できる時間はありません。'
  else
    schedule.each do |s|
      if s[0] == 1 then
        message += "50M 3コースを、"
      elsif s[0] == 2 then
         message += "50M 2コースを、"
      elsif s[0] == 3 then
         message += "25Mコースを、"
      end
      message += to_jikoku(s[1]) + "から"
      message += to_jikoku(s[2]) + "まで利用できます。"
    end
  end
end

puts '{'
puts '  "pool":    ' + '"平塚市総合公園温水プール"' + ','
puts '  "date":    ' + date.strftime('"%Y年%m月%d日"') + ','
puts '  "events":  ' + events.to_s + ','
puts '  "status":  ' + status.to_s + ', '
puts '  "message": ' + sprintf('"%s"', message)
puts '}'
