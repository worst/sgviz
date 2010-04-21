#!/usr/bin/env ruby

require 'socket'

nodes = ["dog", "cat", "bird", "horse", "tree", "car", "phone"]

tags = ["work", "friend", "school"]

t = TCPSocket.new('localhost', 5204)

100.times do |i|

  nodes.shuffle!
  s = "add_node #{nodes[0]}"
  puts s
  t.puts s


  
  nodes.shuffle!
  tags.shuffle!
  s = "add_edge #{nodes[0]} #{nodes[1]} #{tags[0]}"
  puts s
  t.puts s
  

  nodes.shuffle!
  tags.shuffle!
  # note that the visualization expects weights to be floating point...
  s = "update_edge #{nodes[0]} #{nodes[1]} #{tags[0]} #{rand(10) + 1}.0"
  puts s
  t.puts s
  
  sleep rand 0
end

# t.puts "add_node dog"
# 
# t.puts "add_node cat"
# 
# t.puts "add_node cat"
# 
# t.puts "add_edge dog cat work"
# 
# t.puts "update_edge dog cat work 3.0"