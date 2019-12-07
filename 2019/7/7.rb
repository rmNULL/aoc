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
    addr_modes = [org_code[-3] || '1']
  else
    addr_modes = ([(op_code == 4) ? '0' : '1'] + code[1...-2].chars).reverse
  end
  [addr_modes, op_code]
end

def run(mem)
  prg, idx = mem
  idx ||= 0

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

    mem[1] = idx

    # here for the ampi
    if opr == 4
      return
    end

  end

  return :halt
end


org =
  if ARGV.first
    open(ARGV.first) { |f| f.read.split(',') }
  else
    $stdin.read.split(',')
  end

[0..4, 5..9].each_with_index do |ps_range, part|

  osig = [*ps_range].permutation(5).reduce(0) do |large_sig, phase_settings|
    amps = 5.times.map { [org.dup, 0] }
    sig = 0

    last_sig = 0
    phase_settings.cycle.with_index do |ps, amp|
      $IN.push sig
      $IN.push ps if amp < 5
      amp = amp % amps.size
      inst = run(amps[amp])
      sig = $OUT.pop

      if amp == 4
        last_sig = sig if sig
        break if inst == :halt
      end
    end

    [last_sig, large_sig].max
  end

  puts "Part #{part + 1} = #{osig}"
end
