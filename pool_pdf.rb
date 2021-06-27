require 'date'
require 'open-uri'
require 'nokogiri'

class PoolPdf
  attr_accessor :pdf

  BASE_URL = 'http://www.city.hiratsuka.kanagawa.jp'
  POOL_URL = BASE_URL + '/koen/page-c_00812.html'
  PDF_FILE_NAME = "pool.pdf"

  @pdf = nil

  def initialize(date)
    @date = date
    pdf_url = PoolPdf::get_pdf_url(@date)
    @pdf = PoolPdf::download_link(pdf_url)
    File.write(PDF_FILE_NAME, @pdf)
  end

  def self.get_pdf_url(date)
    html = URI.open(POOL_URL) do |f|
      f.read
    end
#    puts html

    page = Nokogiri::HTML.parse(html, nil, 'UTF-8')
    reiwa = date.year - 2018
    reiwa_to_s = reiwa == 1 ? "元" : reiwa.to_s
    month_to_s = date.month.to_s
    keyword = "温水プール利用形式令和#{reiwa_to_s}年#{month_to_s}月"
    xpath = "//p[contains(text(),'温水プールの予定')]"
    page.xpath(xpath).each do |p|
      offset = 1
      pdf_urls = {}
      p.xpath("a" % keyword).each_with_index do |a, i|
        if i > 1 then offset = 2 end
        label = p.xpath("text()[#{i + offset}]").text().gsub(/　/," ").strip()
        href = a[:href]
#        puts label + ":" + href
        pdf_urls[label] = href
      end
      return BASE_URL + pdf_urls[keyword]
    end
  end

  def self.download_link(pdfurl)
    URI.open(pdfurl, 'rb') do |file|
      return file.read
    end
  end
end

if $0 == __FILE__ then
  date = Date.today + ARGV[1].to_i
  pdf_url = PoolPdf::get_pdf_url(date)
  puts pdf_url
  
  PoolPdf.new(date)
end
