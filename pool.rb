require_relative 'pool_pdf.rb'
require_relative 'pool_event.rb'
require_relative 'pool_time.rb'

date = Date.today + ARGV[0].to_i
pool_pdf = PoolPdf.new(date)

pool_event = PoolEvent.new(PoolPdf::PDF_FILE_NAME)
events = pool_event.get_events(date.day)

pool_time = PoolTime.new(PoolPdf::PDF_FILE_NAME, date.month)
status = pool_time.get_status_list(date.day)
schedule = PoolTime::get_schedule(status)

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
        message += "50メートル 3コースを、"
      elsif s[0] == 2 then
         message += "50メートル 2コースを、"
      elsif s[0] == 3 then
         message += "25メートルコースを、"
      end
      message += PoolTime::to_jikoku(s[1]) + "から"
      message += PoolTime::to_jikoku(s[2]) + "まで利用できます。"
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
