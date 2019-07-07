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
    html = open(POOL_URL) do |f|
      f.read
    end
    # puts html

    page = Nokogiri::HTML.parse(html, nil, 'UTF-8')
    reiwa = date.year - 2018
    reiwa_to_s = reiwa == 1 ? "元" : reiwa.to_s
    keyword = "温水プール予定表　令和" + reiwa_to_s + "年" + date.month.to_s + "月"
    # puts keyword
    pdf_url = BASE_URL
    page.xpath("//a[contains(text(), '%s')]" % keyword).each do |a|
      # puts a
      pdf_url = pdf_url +  a[:href]
    end
    if pdf_url == BASE_URL then
      raise "URLリンクが見つかりません。"
    end

    return pdf_url
  end

  def self.download_link(pdfurl)
    open(pdfurl, 'rb') do |file|
      return file.read
    end
  end
end

if $0 == __FILE__ then
  date = Date.today + ARGV[1].to_i
  PoolPdf.new(date)
end
