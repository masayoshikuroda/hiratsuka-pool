require 'stringio'

def to_name(rgb)
  if rgb == "ffffff" then
    return "w"
  elsif rgb == "000000" then
    return "b"
  elsif rgb == "ff0000" then
    return "r"
  elsif rgb == "ffff00" then
    return "y"
  elsif rgb == "92cddc" then
    return "a"
  elsif rgb == "ff99cc" then
    return "p"
  else
    return rgb
  end
end

X = 149
Y = 240
W = 680
H = 1011

WBOX30MIN = 26 # 8:30 - 21:30

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

day = ARGV[0].to_i
y = Y + (day-1) * H/31
cmd = "pdftoppm -f 1 -l 1  -x #{X} -y #{y} -W #{W} -H #{H/31} pool.pdf"
#p cmd
ppm = `#{cmd}`
#p ppm

StringIO.open(ppm) do |sio|
  format = sio.readline.rstrip
  wh = sio.readline.rstrip.split(' ')
  width = wh[0].to_i
  height = wh[1].to_i
  depth = sio.readline.rstrip.to_i
#  puts "format: #{format}, width: #{width}, height: #{height}, depth: #{depth}"

  pixels = Array.new(height){Array.new(width)}
  for h in 0...height do
     for w in 0...width do
       rgb = sio.read(3).unpack("C*")
       pixels[h][w] = sprintf("%02x%02x%02x", rgb[0], rgb[1], rgb[2])
     end
     # p h, pixels[h].map{|i| to_name(i)}
  end

  w30min = width/(WBOX30MIN.to_f + 0)
#  puts "pixels per 30 min: " + w30min.to_s

  status = Array.new(WBOX30MIN, 0)
  for m in 0...WBOX30MIN do
#    print m.to_s + "\t" +  (m*30/60.0 + 8.5).to_s + "\t"
    hist = {}
    for h in 0...pixels.length do
      wstart = CWIDTH[m][0]
      wstop = CWIDTH[m][1]
#      p  m.to_s + ": " + wstart.to_s + " - " + wstop.to_s
      for w in wstart...wstop do
        if not hist.has_key?(pixels[h][w]) then
          hist[pixels[h][w]] = 0 
        end
        hist[pixels[h][w]] = hist[pixels[h][w]] + 1
      end
#      p pixels[h].slice(wstart...wstop).map{|i| to_name(i)}
    end

    max_count = 0
    max_key =""
    hist.each{|key, count|
      if count > max_count then
        max_count = count
        max_key = key
      end     
    }
#    print max_key + "\t"
    if (max_key == "ffffff") then
      status[m] = 0 # empty
    elsif max_key == "ffff00" then
      status[m] = 1 # 50m 3 courses
    elsif max_key == "92cddc" then
      status[m] = 2 # 50m 2 courses
    elsif max_key == "ff99cc" then
      status[m] = 3 # 25m
    else
      status[m] = 0 # red?
    end
#    p status[m]
  end
  
  puts status.join(",")
end
