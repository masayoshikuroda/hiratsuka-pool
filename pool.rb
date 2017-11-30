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
status = get_status_list(pdf_name, PAGE, X, Y, W, H, date.day)

puts "{"
puts '  "events": ' + events.to_s + ", "
puts '  "status": ' + status.to_s
puts "}"
