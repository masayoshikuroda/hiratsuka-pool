
require_relative 'pool_pdf.rb'
require_relative 'pool_pixmap.rb'

class PoolTime
  PDF_PAGE_NUM = 1
  W = 680
  H = 1011

  CWIDTH = [
  	[  0, 19,  8.5,  9.0], #  0: 08:30 - 09:00
  	[ 20, 39,  9.0,  9.5], #  1: 09:00 - 09:30
  	[ 40, 67,  9.5, 10.0], #  2: 09:30 - 10:00
  	[ 68, 94, 10.0, 10.5], #  3: 10:00 - 10:30
  	[ 95,120, 10.5, 11.0], #  4: 10:30 - 11:00
  	[121,148, 11.0, 11.5], #  5: 11:00 - 11:30
  	[149,175, 11.5, 12.0], #  6: 11:30 - 12:00
  	[176,203, 12.0, 12.5], #  7: 12:00 - 12:20
  	[204,230, 12.5, 13.0], #  8: 12:30 - 13:00
  	[231,257, 13.0, 13.5], #  9: 13:00 - 13:30
  	[258,284, 13.5, 14.0], # 10: 13:30 - 14:00
  	[285,312, 14.0, 14.5], # 11: 14:00 - 14:30
  	[313,338, 14.5, 15.0], # 12: 14:30 - 15:00
  	[339,366, 15.0, 15.5], # 13: 15:00 - 15:30
  	[367,393, 15.5, 16.0], # 14: 15:30 - 16:00
  	[394,421, 16.0, 16.5], # 15: 16:00 - 16:30
  	[422,446, 16.5, 17.0], # 16: 16:30 - 17:00
  	[447,475, 17.0, 17.5], # 17: 17:00 - 17:30
  	[476,502, 17.5, 18.0], # 18: 17:30 - 18:00
  	[503,530, 18.0, 18.5], # 19: 18:00 - 18:30
  	[531,556, 18.5, 19.0], # 20: 18:30 - 19:00
  	[557,584, 19.0, 19.5], # 21: 19:00 - 19:30
  	[585,611, 19.5, 20.0], # 22: 19:30 - 20:00
  	[612,639, 20.0, 20.5], # 23: 20:00 - 20:30
  	[640,658, 20.5, 21.0], # 24: 20:30 - 21:00
  	[659,679, 21.0, 21.5]  # 25: 21:00 - 21:30
  ]

  def initialize(pdf_name, month)
    if month == 11 then
      x = 149
      y = 240
    else
      x = 160
      y = 275
    end

    @pixmap = Pixmap.new
    @pixmap.init_from_pdf(pdf_name, PDF_PAGE_NUM, x, y, W, H)
  end

  def get_status(day, wstart, wlength)
    hlength = @pixmap.height / 31
    hstart = (day - 1) * hlength

    clip_pixmap = @pixmap.clip(hstart, hlength, wstart, wlength)
    rgb = clip_pixmap.get_max_rgb
    status = PoolTime::to_status(rgb)

    return status
  end

  def self.to_status(rgb)
    return case rgb
      when "#ffffff" then
        0 # empty
      when "#ffff00" then
        1 # 50m 3 courses
      when "#92cddc" then
        2 # 50m 2 courses
      when "#ff99cc" then
        3 # 25m
      else
        0 # red?
    end
  end


  def get_status_list(day)
    list = CWIDTH.map do |cdwidth|
      wstart = cdwidth[0]
      wlength = cdwidth[1] - wstart
      get_status(day, wstart, wlength)
    end
    return list
  end

  def self.get_schedule(status)
    scwa = CWIDTH.map.with_index{|cw, i| [ status[i], cw[2], cw[3] ]}

    schedule = []
    target = scwa[0]
    scwa.each do |item|
      if item[0] == target[0] then
        target[2] = item[2]
      else
        schedule.push target
        target = item
      end
    end
    schedule.push target

    schedule = schedule.select{|s| s[0] != 0 }
    return schedule
  end

  def self.to_jikoku(val)
  	hm = val.to_s.split(".")
    jikoku = hm[0] + "時"
    jikoku += hm[1] == "0" ? "" : "30分"
    return jikoku
  end
end

#date = Date.today + ARGV[0].to_i
#pool_pdf = PoolPdf.new(date)
#pool_time = PoolTime.new(PoolPdf::PDF_FILE_NAME, date.month)
#status_list = pool_time.get_status_list(date.day)
#p status_list
#p PoolTime::get_schedule(status_list)
