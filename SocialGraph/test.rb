require 'socket'

t = TCPSocket.new('localhost', 5204)

t.puts "add_node dog"