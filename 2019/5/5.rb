#!/usr/bin/env ruby
require 'pp'
OPS = [
  nil,
  # inc_by,operation
  [4, ->(y, x) { x + y }],
  [4, ->(y, x) { x * y }],
  [2, ->() { $stdin.readline.to_i }],
  [2, ->(val) { puts val }],
  [3, ->(y, x) { {jump: y} if x.nonzero? }],
  [3, ->(y, x) { {jump: y} if x.zero? }],
  [4, ->(y, x) { y < x ? 1 : 0}],
  [4, ->(y, x) { x == y ? 1 : 0 }],
]

def disassemble(org_code)
  # pad left positions with zeros
  code = org_code.rjust(5, '0')
  op_code = code[-2...].to_i
  if op_code == 3
    addr_modes = [ org_code[-3] || '1']
  else
    addr_modes = ([(op_code == 4) ? '0' : '1'] + code[1...-2].chars).reverse
  end
  [addr_modes, op_code]
end

def run(prg)
  idx = 0

  until (code = prg[idx]).end_with? "99"
    addr_modes, opr = disassemble(code)
    off, fn = OPS[opr]

    raw_params = prg[(idx+1)...(idx+off)]

    *params, res_addr = raw_params.zip(addr_modes).map do |(pm, mode)|
      pm = pm.to_i
      mode == '1' ? pm : prg[pm].to_i
    end

    # ughh!! whole abstraction broke down here
    if opr == 4 || opr.between?(5, 6)
      params = [res_addr] + params
    end

    res = fn[*params]
    if res && (res.is_a? Numeric)
      prg[res_addr] = res.to_s
    end

    if res && (res.is_a? Hash)
      idx = res[:jump]
    else
      idx += off
    end

  end

  return prg
end


org =
  if ARGV.first
    open(ARGV.first) { |f| f.read.split(',') }
  else
    $stdin.read.split(',')
  end

run(org)
