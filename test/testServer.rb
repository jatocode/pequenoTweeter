#!/usr/bin/ruby
require './server.rb'

server = Server::Status.new
server.test

last_tweet = File.open('/var/cache/pequenoTweeter/last_tweet') {|f| f.readline}

puts "Last update-tweet: #{Time.at(last_tweet.to_i)}"


