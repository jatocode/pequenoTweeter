#!/usr/bin/ruby
require './server.rb'

server = Server::Status.new
server.test

t = Time.new
puts t
