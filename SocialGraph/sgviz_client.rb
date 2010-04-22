#!/usr/bin/env ruby

require 'rubygems'
require 'socket'
require 'file/tail'

filename = ARGV[0]
peer_id = ARGV[1]
send_to = ARGV[2]
# send_to_port = ARGV[3]


File.open(filename) do |log|
  
  r_add_node = /:initialize (\w+):add_node (\w+)/
  r_add_edge = /:initialize (\w+):add_edge (\w+) (\w+) (\w+) (\d+.\d+)/
  r_update_edge = /:initialize (\w+):update_edge (\w+) (\w+) (\w+) (\d+.\d+)/
  
  t = STDOUT
  if !send_to.nil?
    t = TCPSocket.new(send_to, 5204)
  end
  
  
  
  # cmds = []
  #   cmds << r_add_node
  #   cmds << r_add_edge
  #   cmds << r_update_edge
  
  
  log.extend(File::Tail)
  log.interval = 10
  log.backward(log.lines.to_a.length)
  log.tail do |line|
    if !(match = r_add_node.match(line)).nil?
      puts "*"*20
      puts "Node added:"
      puts line
      puts r_add_node
      puts "-"*20
      # match.captures.each {|m| puts m}
      from_node = match.captures[0]
      to_node = match.captures[1]
      t.puts "add_node #{peer_id} #{to_node}"

      # set the node to trusted if necessary
      t.puts "set_trusted #{peer_id} #{to_node}" if from_node == to_node
      #next
      puts "*"*20
    elsif !(match = r_add_edge.match(line)).nil?
      # found an add edge
      puts "*"*20
      puts "Edge added"
      from_node = match.captures[1]
      to_node = match.captures[2]
      tag = match.captures[3]
      weight = match.captures[4].to_f

      puts "from_node: #{from_node}"
      puts "to_node: #{to_node}"
      puts "tag: #{tag}"
      puts "weight: #{weight}"

      t.puts "add_edge #{peer_id} #{from_node} #{to_node} #{tag}"
      # t.puts "update_edge #{peer_id} #{from_node} #{to_node} #{tag} #{weight}"
      puts "*"*20
    elsif !(match = r_update_edge.match(line)).nil?
      from_node = match.captures[1]
      to_node = match.captures[2]
      tag = match.captures[3]
      weight = match.captures[4].to_f
      puts "*"*20
      t.puts "update_edge #{peer_id} #{from_node} #{to_node} #{tag} #{weight}"
      puts "*"*20
    end
  end
end