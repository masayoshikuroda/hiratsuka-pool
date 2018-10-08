require 'date'
require 'pdftotext'
require_relative 'pool_pdf.rb'

class PoolEvent
  PDF_ROW_OFFSET = 6
  PDF_PAGE_NUM = 1

  def initialize(pdf_name)
    @lines = PoolEvent::get_pdf_text(pdf_name, PDF_PAGE_NUM, PDF_ROW_OFFSET)
  end

  def self.get_day_filter(day)
    filter = day.to_s.tr('0-9', '０-９') + '日'
    filter = " " + filter if (day < 10)
    # puts filter
    return filter
  end

  def self.get_pdf_text(pdf_name, page_number, row_offset)
    #cmd = "pdftotext - - -l #{page_number} -l #{page_number} -layout"
    #text = `cmd`
    pages = Pdftotext.pages(pdf_name)
    text = pages[page_number - 1].text
    # puts text
    lines = text.split(/\r?\n/).slice(row_offset, 31)
    # p lines
    return lines
  end

  def self.to_events(line, filter)
    fields = line.split(filter)
    field = fields[1].lstrip
    #p field
    events = field.slice(1, field.length - 2).strip
    return events.split(" ").find_all{|s| not s.empty?}
  end

  def self.format_events(events)
    events = events.map{|s| s.sub(/※県水連/, '水泳指導員養成講習会')}
    events = events.map{|s| s.sub(/体協/,    '県体協水泳教室')}
    events = events.map{|s| s.sub(/財団/,    '財団水泳教室')}
    events = events.map{|s| s.sub(/アクア/,  'アクアビス教室')}
    events = events.map{|s| s.sub(/水泳体操/, 'はつらつ水泳体操')}
    events = events.map{|s| s.sub(/消防/,    '平塚消防水難訓練')}
    return events
  end

  def get_events(day=nil)
    if day.nil? then day = @date.day end
    filter = PoolEvent::get_day_filter(day)
    line = @lines.find{|l| l.include?(filter)}
    # p line
    if line.nil? then
      return []
    else
      return PoolEvent::format_events(PoolEvent::to_events(line, filter))
    end
  end
end

if $0 == __FILE__ then
  date = Date.today + ARGV[0].to_i
  pool_pdf = PoolPdf.new(date)
  pool_event = PoolEvent.new(PoolPdf::PDF_FILE_NAME)
  p pool_event.get_events(date.day)
end
