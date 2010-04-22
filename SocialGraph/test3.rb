#!/usr/bin/env ruby

require 'socket'

nodes = []
peers = ["peer1", "peer2", "peer3", "peer4"]
tags = ["work", "friend", "school"]

t = TCPSocket.new('localhost', 5204)

1000.times do |i|

  peers.shuffle!
  nodes.shuffle!
  nodes << i
  s = "add_node #{peers[0]} #{i}"
  puts s
  t.puts s

  if nodes.length > 1
    peers.shuffle!
    nodes.shuffle!
    tags.shuffle!
    s = "add_edge #{peers[0]} #{nodes[0]} #{nodes[1]} #{tags[0]} #{rand(5) + 1}.0"
    puts s
    t.puts s

    peers.shuffle!
    nodes.shuffle!
    tags.shuffle!
    # note that the visualization expects weights to be floating point...
    s = "update_edge #{peers[0]} #{nodes[0]} #{nodes[1]} #{tags[0]} #{rand(5) + 1}.0"
    puts s
    t.puts s
  end

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