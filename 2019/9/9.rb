#!/usr/bin/env ruby
require 'pp'
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

    mem[1..2] = idx, ridx

  end

  return :halt
end

prgm = ARGF.read.strip.split(',')
2.times do |part|
  mem = [prgm.dup, 0, 0]
  $IN.push (part+1)
  run(mem)
  puts "Part #{part+1} = #{$OUT}"

  $IN.clear
  $OUT.clear
end
