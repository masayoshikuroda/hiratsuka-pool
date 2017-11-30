require 'date'
require 'open-uri'
require 'nokogiri'
require 'pdftotext'

def get_day_filter(day)
  filter = day.to_s.tr('0-9', '０-９') + '日'
  filter = " " + filter if (day < 10)
  # puts filter
  return filter
end

def get_pdf_text(pdf_name, page, x)
  cmd = "pdftotext -f #{page} -l #{page} -layout #{pdf_name} -"
  # puts cmd
  text = `#{cmd}`
  # puts text
  lines = text.split(/\r?\n/).slice(x, 31)
  # p lines
  return lines
end

def to_events(line, filter)
  fields = line.split(filter)
  field = fields[1].lstrip
  #p field
  events = field.slice(1, field.length - 2).strip
  return events.split(" ").find_all{|s| not s.empty?}
end

def get_events(pdf_name, page, x, day)
  lines = get_pdf_text(pdf_name, page, x)
  filter = get_day_filter(day)
  line = lines.find{|l| l.include?(filter)}
  # p line
  if line.nil? then
    return []
  else
    return to_events(line, filter)
  end
end

# puts get_events(ARGV[0], 6, ARGV[1].to_i)
