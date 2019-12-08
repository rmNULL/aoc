#!/usr/bin/env ruby
require 'pp'
img = ARGF.read

WIDTH = 25
HEIGHT = 6
layers = img.chars.each_slice(WIDTH * HEIGHT)

# part 0
layers.min_by { |l| l.count('0') }.tap { |l| p l.count('1') * l.count('2') }

PAINT =
  begin
    require 'paint'
    b = Paint[' ', nil, :red]
    w = Paint[' ', nil, :yellow]
    [b, w]
  rescue LoadError
    [' ', "o"]
  end

# part 1
re_img = (HEIGHT * WIDTH).times.reduce([]) do |img, pix|
  col = (pix % WIDTH)
  row = pix / WIDTH
  img[row] ||= []

  color = layers.find { |l| l[pix] != '2' }[pix].to_i
  img[row][col] = PAINT[color]
  if col == (WIDTH - 1)
    img[row] = img[row].join()
  end
  img
end

puts re_img
