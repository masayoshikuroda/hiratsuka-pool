require 'stringio'
require_relative 'pool_pdf.rb'

class Pixmap
  attr_accessor :format, :width, :height, :pixels

  def initialize()
    @format = "P6"
    @width = 0
    @height = 0
    @pixels = Array.new(@height){Array.new(@width)}
  end

  def init_from_pdf(pdf_name, page, x, y, w, h)
    cmd = "pdftoppm -f #{page} -l #{page} -x #{x} -y #{y} -W #{w} -H #{h} #{pdf_name}"
    # p cmd
    ppm = `#{cmd}`
    # p ppm
    init_from_ppm(ppm)
  end

  def init_from_ppm(ppm)
    StringIO.open(ppm) do |sio|
      @format = sio.readline.rstrip
      wh = sio.readline.rstrip.split(' ')
      @width = wh[0].to_i
      @height = wh[1].to_i
      @depth = sio.readline.rstrip.to_i
      # puts "format: #{format}, width: #{width}, height: #{height}, depth: #{depth}"

      @pixels = Array.new(@height){Array.new(@width)}

      for h in 0...@height do
        for w in 0...@width do
           rgb = sio.read(3).unpack("C*")
           @pixels[h][w] = sprintf("#%02x%02x%02x", rgb[0], rgb[1], rgb[2])
           # p h, w, rgb, @pixels[h][w]
         end
          # p h, @pixels[h].map{|i| to_name(i)}
      end
    end
  end

  def clip(hstart, hlength, wstart, wlength)
    c = Pixmap.new
    c.format = @format
    c.width = wlength
    c.height = hlength

    pixels =  @pixels.select.with_index {|pixel, i|  hstart <= i && i < hstart + hlength}
    c.pixels = pixels.map{|pixel| pixel.slice(wstart, wlength)}

    return c
  end

  def get_hist()
    hist = {}
    for h in 0...@pixels.length do
      for w in 0...@pixels[h].length do
        hist[@pixels[h][w]] = hist.fetch(@pixels[h][w], 0) + 1
      end
      # p pixels[h].slice(wstart...wstop).map{|c| to_name(c)}
    end
    return hist
  end

  def get_max_rgb
    hist = get_hist()
    max_count = 0
    max_rgb = ""
    hist.each do |rgb, count|
      if count > max_count then
        max_count = count
        max_rgb = rgb
      end
    end
    return max_rgb;
  end

  def self.to_name(rgb)
    p rgb
    return case rgb
      when "#ffffff" then
        "w" # white
      when "#000000" then
        "b" # blue
      when "#ff0000" then
        "r" # reg
      when "#ffff00" then
        "y" # yellow
      when "#92cddc" then
        "a" # aqua
      when "#ff99cc" then
        "p" # pink
      else
        rgb
    end
  end
end

#date = Date.today + ARGV[0].to_i
#pool_pdf = PoolPdf.new(date)
#pixmap = Pixmap.new
#pixmap.init_from_pdf(PoolPdf::PDF_FILE_NAME, 1, 160, 275, 680, 1011)
#day1 = pixmap.clip(0, 1011/31, 0, 680)
#p day1.get_hist
#p day1.get_max_rgb
#p Pixmap::to_name(day1.get_max_rgb)
