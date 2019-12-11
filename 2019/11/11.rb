#!/usr/bin/env ruby
require 'pp'
require 'set'

$OUT = []
$IN = []

OPS = [
  nil,
  # inc_by,operation
  [4, ->(y, x) { x + y }],
  [4, ->(y, x) { x * y }],
  [2, ->() { $IN.pop.to_i }],
  [2, ->(val) { $OUT.push val }],
  [3, ->(y, x) {  {jump: y} if x.nonzero? }],
  [3, ->(y, x) { {jump: y} if x.zero? }],
  [4, ->(y, x) { y < x ? 1 : 0}],
  [4, ->(y, x) { x == y ? 1 : 0 }],
  [2, ->(radd) { {radd: radd} } ]
]

def disassemble(org_code)
  # pad left positions with zeros
  code = org_code.rjust(5, '0')
  op_code = code[-2...].to_i

  addr_modes = (code[0...-2].chars).reverse
  [addr_modes, op_code]
end

def run(mem)
  prg, idx, ridx = mem
  idx ||= 0
  ridx ||= 0

  until (code = prg[idx]).end_with? "99"
    addr_modes, opr = disassemble(code)
    off, fn = OPS[opr]
    write_op = [1,2,3,7,8].include?(opr)

    raw_params = prg[(idx+1)...(idx+off)]

    *params, res_addr = raw_params.zip(addr_modes).map.with_index do |(pm, mode), i|
      pm = pm.to_i
      relative = mode == '2'
      if write_op && (raw_params.length.pred == i)
        relative ? (ridx + pm) : pm
      else
        mode == '1' ? pm : prg[relative ? (ridx + pm) : pm].to_i
      end
    end

    if opr == 9 || opr.between?(4, 6)
      params = [res_addr] + params
    end

    res = fn[*params]

    if (res.is_a? Hash) and res[:jump]
      idx = res[:jump]
    else
      idx += off
    end

    if (res.is_a? Hash) and res[:radd]
      ridx = ridx + res[:radd]
    end

    if (res.is_a? Numeric)
      prg[res_addr] = res.to_s
    end

    if opr == 4 && $OUT.size == 2
      next_ip = yield $OUT
      $OUT.pop 2
      $IN.push next_ip
    end

    mem[1..2] = idx, ridx

  end

  return :halt
end

def positive_deg deg
  deg % 360
end

def cord_add p1, p2
  [p1[0] + p2[0],
   p1[1] + p2[1]
  ]
end


prgm = ARGF.read.strip.split(',')

@move_by = [
# [ x,  y]
  [ 0, -1], # 0 deg
  [ 1,  0], # 90 deg
  [ 0,  1], # 180 deg
  [-1,  0] # 270 deg
]

2.times do |part|

  mem = [prgm.dup, 0, 0]
  @facing_dir = 0
  @pos = [0,0]
  panels = {}

  $IN.push part
  run(mem) do |(clr, turn)|
    panels[@pos] = clr
    @facing_dir = positive_deg([-90,90][turn] + @facing_dir)
    off = @move_by[ @facing_dir / 90 ]
    @pos = cord_add @pos, off
    panels[@pos] || 0
  end

  if part == 0
    puts "part 1 =  #{panels.size}"
    next
  end


  puts "part 2"

  # part2
  PAINT =
    begin
      require 'paint'
      b = Paint[' ', nil, :red]
      w = Paint[' ', nil, :yellow]
      [b, w]
    rescue LoadError
      [' ', "o"]
    end

  ## all are positive examples
  panels.keys.tap { |cords|
    # +1 as indexing stars from zero
    HEIGHT = cords.max[0] + 1
    WIDTH = cords.max_by { |c| c[1] }[1] + 1
  }

  img = Array.new(WIDTH) { Array.new(HEIGHT, PAINT[0]) }

  panels.each do |(row, col), color|
    img[col][row] = PAINT[color]
  end

  img.each { |r| puts r.join }

end
