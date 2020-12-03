#!/usr/bin/env ruby
# frozen_string_literal: true

def count_trees(xd, yd=1)
  in_f = ARGV.first ? File.open(ARGV.first) : ARGF
  n_trees = in_f.readlines.drop(1).reduce([xd, 1, 0]) do |(xpos, ypos, n_trees), line|
    if (ypos % yd).zero?
      x_repeat = line.strip.length
      tree_found = line.strip[xpos % x_repeat] == '#'
      [xpos + xd, ypos + 1, n_trees + (tree_found ? 1 : 0)]
    else
      [xpos, ypos + 1, n_trees]
    end
  end[2]
  in_f.rewind
  n_trees
end

# 1
puts(count_trees(3))

# 2
puts([[1], [3], [5], [7], [1, 2]].reduce(1) { |r, n| count_trees(*n) * r })
