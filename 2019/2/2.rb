OPS = [nil, '+', '*']
def assist(prg)
  idx = 0
  while (opr = prg[idx]) != 99
    p1, p2, res = prg.values_at( prg[idx+1], prg[idx+2], idx+3 )
    prg[res] = p1.send OPS[opr], p2
    idx += 4
  end

  return prg[0]
end


f =
  if ARGV.first
    open(ARGV.first)
  else
    $stdin
  end

org = f.read.split(',').map &:to_i

# 99, is puzzle constraint
to = [org.size.pred, 99].min

(0..to).each do |noun|
  (0..to).each do |verb|

    pgm = [org[0], noun, verb] + org[3..-1]
    output = assist(pgm)

    if noun == 12 && verb == 2
      puts "Part 1: #{output}"
    end

    if  output == 19690720
      puts "Part 2: #{(100 * noun) + verb}"
      break
    end
  end
end
