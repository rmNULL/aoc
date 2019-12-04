def never_decrease?(n)
  n.to_s.chars.chunk_while { |d,nd| d <= nd }.count == 1
end

def any_adj_group(n)
  n.to_s.chars.chunk_while { |d, nd| d == nd }.any? { |grp| yield grp }
end


rstart = 357253
rend = 892942
range = (rstart .. rend)
# no need to consider within range and length == 6 as all the digits in our
# range is 6digits.

def solve(range)
  valid_passwords = range.filter do |n|
    never_decrease?(n) && any_adj_group(n) { |grp| yield grp }
  end
  valid_passwords.count
end

def part1(range)
  solve(range) { |grp| grp.size >= 2 }
end

def part2(range)
  solve(range) { |grp| grp.size == 2 }
end

puts part1(range), part2(range)
