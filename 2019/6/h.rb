#!/usr/bin/env ruby
require 'set'

def count_orbiters(tree, from, target="COM", acc=0)
  if from == target
    acc
  else
    count_orbiters(tree, tree[from], target, acc+1)
  end
end


def path_to_com(tree, key)
  path = []
  while key
    path.push key
    key = tree[key]
  end
  path
end

def part1 tree
  total = tree.sum do |child, par|
    count_orbiters(tree, child)
  end
  total
end

def  part2 tree
  xp = Set.new path_to_com(tree, tree['YOU'])
  yp = Set.new path_to_com(tree, tree['SAN'])
  common_orbit = (xp & yp).first
  total_dist = (count_orbiters(tree, tree['YOU'], common_orbit) +
                count_orbiters(tree, tree['SAN'], common_orbit)
               )
  total_dist
end


if __FILE__ == $0
  f = ARGV.first || 'ip.txt'
  lines = open(f) {|f| f.readlines}
  tree = lines.reduce({}) do |tree, line|
    par, child = line.split(')').map &:strip
    tree[child] = par
    tree
  end

  p part1(tree)
  p part2(tree)
end
