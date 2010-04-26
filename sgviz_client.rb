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
  r_visit = /:visit (\w+) (\w+)/
  r_add_node2 = /:add_node (\w+)/
  r_add_edge2 = /:add_edge (\w+) (\w+) (\w+) (\d+.\d+)/
  r_update_edge2 = /:update_edge (\w+) (\w+) (\w+) (\d+.\d+)/
  
  r_trust = /:trust (\w+)/
  r_acl_blocked = /:acl_blocked (\w+)/
  
  
  t = STDOUT
  if !send_to.nil?
    # It's not that pretty to keep a telnet session open the entire time, but
    # whatever.
    t = TCPSocket.new(send_to, 5204)
  end
  
  
  # really want to make the #tail block less convoluted
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
      if !send_to.nil?
        # It's not that pretty to keep a telnet session open the entire time, but
        # whatever.
        t = TCPSocket.new(send_to, 5204)
      end
      t.puts "add_node #{peer_id} #{to_node}"
      if !send_to.nil?
        t.close
      end

      # set the node to trusted if necessary
      if !send_to.nil?
        # It's not that pretty to keep a telnet session open the entire time, but
        # whatever.
        t = TCPSocket.new(send_to, 5204)
      end
      t.puts "set_trusted #{peer_id} #{to_node}" if from_node == to_node
      if !send_to.nil?
        t.close
      end
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

      if !send_to.nil?
        # It's not that pretty to keep a telnet session open the entire time, but
        # whatever.
        t = TCPSocket.new(send_to, 5204)
      end
      t.puts "add_edge #{peer_id} #{from_node} #{to_node} #{tag} #{weight}"
      if !send_to.nil?
        t.close
      end
      # t.puts "update_edge #{peer_id} #{from_node} #{to_node} #{tag} #{weight}"
      puts "*"*20
    elsif !(match = r_update_edge.match(line)).nil?
      from_node = match.captures[1]
      to_node = match.captures[2]
      tag = match.captures[3]
      weight = match.captures[4].to_f
      
      puts "*"*20
      puts "Updating edge"
      if !send_to.nil?
        # It's not that pretty to keep a telnet session open the entire time, but
        # whatever.
        t = TCPSocket.new(send_to, 5204)
      end
      t.puts "update_edge #{peer_id} #{from_node} #{to_node} #{tag} #{weight}"
      if !send_to.nil?
        t.close
      end
      puts "*"*20
    elsif !(match = r_visit.match(line)).nil?
      from_node = match.captures[0]
      to_node = match.captures[1]
      
      puts "*"*20
      puts "Visiting node"
      if !send_to.nil?
        # It's not that pretty to keep a telnet session open the entire time, but
        # whatever.
        t = TCPSocket.new(send_to, 5204)
      end
      t.puts "visit #{peer_id} #{from_node} #{to_node}"
      if !send_to.nil?
        t.close
      end
      puts "*"*20
    elsif !(match = r_add_node2.match(line)).nil?
      from_node = match.captures[0]
      
      puts "*"*20
      puts "Adding node (non initializer)"
      if !send_to.nil?
        # It's not that pretty to keep a telnet session open the entire time, but
        # whatever.
        t = TCPSocket.new(send_to, 5204)
      end
      t.puts "add_node #{peer_id} #{from_node}"
      if !send_to.nil?
        t.close
      end
      puts "*"*20
    elsif !(match = r_add_edge2.match(line)).nil?
      from_node = match.captures[0]
      to_node = match.captures[1]
      tag = match.captures[2]
      weight = match.captures[3].to_f
      
      puts "*"*20
      puts "Adding edge (non initializer)"
      if !send_to.nil?
        # It's not that pretty to keep a telnet session open the entire time, but
        # whatever.
        t = TCPSocket.new(send_to, 5204)
      end
      t.puts "add_edge #{peer_id} #{from_node} #{to_node} #{tag} #{weight}"
      if !send_to.nil?
        t.close
      end
      puts "*"*20
    elsif !(match = r_update_edge2.match(line)).nil?
      from_node = match.captures[0]
      to_node = match.captures[1]
      tag = match.captures[2]
      weight = match.captures[3].to_f
      
      puts "*"*20
      puts "Updating edge (non initializer)"
      if !send_to.nil?
        # It's not that pretty to keep a telnet session open the entire time, but
        # whatever.
        t = TCPSocket.new(send_to, 5204)
      end
      t.puts "update_edge #{peer_id} #{from_node} #{to_node} #{tag} #{weight}"
      if !send_to.nil?
        t.close
      end
      puts "*"*20
    elsif !(match = r_acl_blocked.match(line)).nil?
      puts "*"*20
      puts "BLOOOOOOOOOOOCKKKKEDDD!!!"
      node = match.captures[0]
      if !send_to.nil?
        # It's not that pretty to keep a telnet session open the entire time, but
        # whatever.
        t = TCPSocket.new(send_to, 5204)
      end
      t.puts "blocked #{peer_id} #{node}"
      if !send_to.nil?
        t.close
      end
    elsif !(match = r_trust.match(line)).nil?
      puts "*"*20
      puts "Trust request"
      node = match.captures[0]
      if !send_to.nil?
        # It's not that pretty to keep a telnet session open the entire time, but
        # whatever.
        t = TCPSocket.new(send_to, 5204)
      end
      t.puts "set_trusted #{peer_id} #{node}"
      if !send_to.nil?
        t.close
      end
    end
  end
end