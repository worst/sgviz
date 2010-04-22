#!/usr/bin/env ruby

require 'socket'

peer_id = ARGV[0]
log_file = ARGV[1]

# initialize (add a node as trusting this peer)
# 2010-04-21 13:56:53,393:initialize 0:add_node 0
# 
# add a node to the graph (not trusted)
# 2010-04-21 13:56:53,393:initialize 0:add_node 128
# 
# add an edge to the graph?
# 2010-04-21 13:56:53,393:initialize 0:add_edge 0 128 school 0.18
# 
# update an existing edge?
# 2010-04-21 13:57:20,457:initialize 0:update_edge 0 10 school 0.1

r_add_node = /[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2},[0-9]{3}:initialize ([0-9a-zA-Z]+):add_node ([0-9a-zA-Z]+)/
r_add_edge = /[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2},[0-9]{3}:initialize ([0-9a-zA-Z]+):add_edge ([0-9a-zA-Z]+) ([0-9a-zA-Z]+) ([\w]+) ([0-9]+.[0-9]+)/
r_update_edge = /[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2},[0-9]{3}:initialize ([0-9a-zA-Z]+):update_edge ([0-9a-zA-Z]+) ([0-9a-zA-Z]+) ([\w]+) ([0-9]+.[0-9]+)/

t = TCPSocket.new('localhost', 5204)

f = File.open(ARGV[1])
f.lines.each do |l|
  
  if !(match = r_add_node.match(l)).nil?
    puts "*"*20
    puts "line matched:"
    puts l
    puts r_add_node
    puts "-"*20
    # match.captures.each {|m| puts m}
    from_node = match.captures[0].to_i
    to_node = match.captures[1].to_i
    t.puts "add_node #{peer_id} #{to_node}"
    
    # set the node to trusted if necessary
    t.puts "set_trusted #{peer_id} #{to_node}" if from_node == to_node
    #next
  elsif !(match = r_add_edge.match(l)).nil?
    # found an add edge
    puts "*"*20
    puts "Edge added"
    from_node = match.captures[1].to_i
    to_node = match.captures[2].to_i
    tag = match.captures[3]
    weight = match.captures[4].to_f
    
    puts "from_node: #{from_node}"
    puts "to_node: #{to_node}"
    puts "tag: #{tag}"
    puts "weight: #{weight}"
    
    t.puts "add_edge #{peer_id} #{from_node} #{to_node} #{tag} #{rand(5) + 1}.0"
    # t.puts "update_edge #{peer_id} #{from_node} #{to_node} #{tag} #{weight}"
    
  end
  
  
  
  
end

f.close