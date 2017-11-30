require 'stringio'

def to_name(rgb)
  return
    case rgb
    when "#ffffff" then "w" # white
    when "#000000" then "b" # blue
    when "#ff0000" then "r" # reg
    when "#ffff00" then "y" # yellow
    when "#92cddc" then "a" # aqua
    when "#ff99cc" then "p" # pink
    else rgb
  end
end

def get_ppm(pdf_name, page, x, y, w, h, day)
  dy = y + (day - 1) * h / 31
  cmd = "pdftoppm -f #{page} -l #{page} -x #{x} -y #{dy} -W #{w} -H #{h/31} #{pdf_name}"
  # p cmd
  ppm = `#{cmd}`
  # p ppm
  return ppm
end

def get_pixels(ppm)
  StringIO.open(ppm) do |sio|
    format = sio.readline.rstrip
    wh = sio.readline.rstrip.split(' ')
    width = wh[0].to_i
    height = wh[1].to_i
    depth = sio.readline.rstrip.to_i
    # puts "format: #{format}, width: #{width}, height: #{height}, depth: #{depth}"

    pixels = Array.new(height){Array.new(width)}
    for h in 0...height do
      for w in 0...width do
         rgb = sio.read(3).unpack("C*")
         pixels[h][w] = sprintf("#%02x%02x%02x", rgb[0], rgb[1], rgb[2])
         # p h, w, rgb, pixels[h][w]
       end
        # p h, pixels[h].map{|i| to_name(i)}
    end

    return pixels
  end
end

def get_hist(pixels, wstart, wstop)
  hist = {}
  for h in 0...pixels.length do
    for w in wstart...wstop do
      hist[pixels[h][w]] = hist.fetch(pixels[h][w], 0) + 1
    end
    # p pixels[h].slice(wstart...wstop).map{|c| to_name(c)}
  end
  return hist
end

def get_peak_color(hist)
  max_count = 0
  max_key = ""
  hist.each do |key, count|
    if count > max_count then
      max_count = count
      max_key = key
    end
  end
  return max_key
end

def to_status(rgb)
  return case rgb
    when "#ffffff" then 0 # empty
    when "#ffff00" then 1 # 50m 3 courses
    when "#92cddc" then 2 # 50m 2 courses
    when "#ff99cc" then 3 # 25m
    else               0 # red?
    end
end

def get_status(pixels, wstart, wstop)
  hist = get_hist(pixels, wstart, wstop)
  # p hist
  rgb = get_peak_color(hist)
  status = to_status(rgb)
  # puts wstart.to_s + " - " + wstop.to_s + ": " + rgb + " = " + status.to_s
  return status
end

CWIDTH = [
  [  0, 19], #  0: 08:30 - 09:00
  [ 20, 39], #  1: 09:00 - 09:30
  [ 40, 67], #  2: 09:30 - 10:00
  [ 68, 94], #  3: 10:00 - 10:30
  [ 95,120], #  4: 10:30 - 11:00
  [121,148], #  5: 11:00 - 11:30
  [149,175], #  6: 11:30 - 12:00
  [176,203], #  7: 12:00 - 12:20
  [204,230], #  8: 12:30 - 13:00
  [231,257], #  9: 13:00 - 13:30
  [258,284], # 10: 13:30 - 14:00
  [285,312], # 11: 14:00 - 14:30
  [313,338], # 12: 14:30 - 15:00
  [339,366], # 13: 15:00 - 15:30
  [367,393], # 14: 15:30 - 16:00
  [394,421], # 15: 16:00 - 16:30
  [422,446], # 16: 16:30 - 17:00
  [447,475], # 17: 17:00 - 17:30
  [476,502], # 18: 17:30 - 18:00
  [503,530], # 19: 18:00 - 18:30
  [531,556], # 20: 18:30 - 19:00
  [557,584], # 21: 19:00 - 19:30
  [585,611], # 22: 19:30 - 20:00
  [612,639], # 23: 20:00 - 20:30
  [640,658], # 24: 20:30 - 21:00
  [659,679]  # 25: 21:00 - 21:30
]

def get_status_list(pdf_name, page, x, y, w, h, day)
  ppm = get_ppm(pdf_name, page, x, y, w, h, day)
  pixels = get_pixels(ppm)

  status = Array.new(CWIDTH.length, 0)
  for i in  0...CWIDTH.length do
    wstart = CWIDTH[i][0]
    wstop  = CWIDTH[i][1]
    status[i] = get_status(pixels, wstart, wstop)
  end
  return status
end

# puts get_status_list(ARGV[0], 1, 149, 249, 680, 1011, ARGV[1].to_i).join(",")
