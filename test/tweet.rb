#!/usr/bin/ruby

gem 'twitter','2.1.0'
require "twitter"
require "./server.rb"

puts "Testing..."
#puts Twitter.user_timeline("tobbe_j").first.text

my_config = YAML.load_file('global.yml')
puts my_config.inspect

Twitter.configure do |config|
  config.consumer_key = my_config[:consumer_key]
  config.consumer_secret = my_config[:consumer_secret]
  config.oauth_token = my_config[:token]
  config.oauth_token_secret = my_config[:secret]
end

#Twitter.update("pequeno tweeting away with a ruby gem.")
#Twitter.update("OK, watch me try to send a DM")

#Twitter.direct_message_create("tobbe_j", "Hej hej. Din server pratar med dig!")

#Twitter.update("No exceptions - guess it worked")
server = Server::Status.new
ip = server.get_address
#Twitter.update("My IP seems to be: #{ip}")
#Twitter.update("I have some users active: #{server.get_users}")
#Twitter.update("My latest reboot was: #{server.get_last_boot} and my uptime is #{server.get_uptime}")
s=""
test = (0x2581..0x2589).to_a
s = test.pack("U*")
puts s
#Twitter.update("Unicode? #{s}")

puts Twitter.rate_limit_status.remaining_hits.to_s + " Twitter API request(s) remaining this hour"
