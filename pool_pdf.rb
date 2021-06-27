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
    keyword = "温水プール利用形式" + date.month.to_s.tr('0-9', '０-９') + "月"
#    puts keyword
    pdf_urls = []
    page.xpath("//a" % keyword).each do |a|
      href = a[:href]
      pdf_urls << href if href.end_with?('.pdf')
    end
    pdf_url = BASE_URL + pdf_urls[pdf_urls.length-2]
    if pdf_url == BASE_URL then
      raise "URLリンクが見つかりません。"
    end

    return pdf_url
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
