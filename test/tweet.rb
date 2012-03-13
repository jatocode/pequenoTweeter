#!/usr/bin/ruby

gem 'twitter','2.1.0'
require "twitter"
require "./server.rb"

puts "Testing..."
#puts Twitter.user_timeline("tobbe_j").first.text

my_config = YAML.load_file('test/test-config.yml')

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

puts "(#{Time.now}) Tweeting: \"#{ARGV[0]}\""
Twitter.update(ARGV[0])
puts Twitter.rate_limit_status.remaining_hits.to_s + " Twitter API request(s) remaining this hour"
