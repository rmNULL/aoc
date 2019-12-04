ns = open('1.txt').map do |l|
  n = l.strip.to_i

  req = ((n / 3) - 2)

  fuel = req

  # for part1 comment the while block.
  while  ((fuel/3) - 2) > 0
    req += ((fuel/3) - 2)
    fuel = ((fuel/3) - 2)
  end
  #
  # end of part2 

  req

end

puts ns.sum
