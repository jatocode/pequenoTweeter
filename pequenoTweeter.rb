#!/usr/bin/env ruby
require 'rubygems'
require 'chatterbot/dsl'
require './server.rb'
gem 'twitter','2.1.0' # Since I'm mixing chatterbot and twitter I need to do this
require "twitter"

# PequenoTweeter 

class PequenoTweeter
    def start
        ## For now, we'll block URLs to keep this from being a source of spam
        exclude "http://"
        blacklist "mean_user, private_user"

        puts "Starting pequenoTweeter. Waiting for replies.."

        begin
        loop do
          replies do |tweet|

            text = tweet[:text] 
            case text.downcase! 
               when /address/, /adress/
                  answer = "#USER# You'll find me at: #{@server.get_address}"
               when /uptime/
                  answer = "#USER# Been up since #{@server.get_uptime}"
               when /users/
                  answer = "#USER# My active users are: #{@server.get_users}"
               when /boot/
                  answer = "#USER# My last reboot was #{@server.get_last_boot}"
               when /top/
                  answer = "#USER# Top process: #{@server.get_top_process}"
               when /hemma/
                  answer = "#USER# Status: #{@server.get_hemma_status}"
               when /help/
                  answer = "#USER# Try address, uptime, users, boot, top, hemma or help"
               else begin
                   answer = "#USER# bash: #{text}: command not found "
                   puts "Unknown command: #{tweet[:text]}"
               end
            end
            puts answer
            # send it back!
            reply answer, tweet

          end
          update_config
          check_ip_change
          hourly_update
          sleep 10

          end
          rescue 
            puts "Something went haywire. Retrying. #{$!}"
            retry
        end
    end

    def initialize
        # Load config
        @my_config = YAML.load_file('pequenoTweeter.yml')

        # Configure twitter gem
        Twitter.configure do |config|
          config.consumer_key = @my_config[:consumer_key]
          config.consumer_secret = @my_config[:consumer_secret]
          config.oauth_token = @my_config[:token]
          config.oauth_token_secret = @my_config[:secret]
        end

        @server = Server::Status.new
    end

    def check_ip_change
        ip = @server.check_ip
        unless ip =~ /No/
            Twitter.direct_message_create("tobbe_j", ip)
        end
    end

    def hourly_update

       base_path = @my_config[:base_path]
       last_tweet = File.open("#{base_path}/last_tweet") {|f| f.readline}
       last_update = Time.at(last_tweet.to_i)

       now = Time.new
       if now-last_update > 3600 
           File.open("#{base_path}/last_tweet",'w') {|f| f.puts now.to_i}
           fortune = %x[fortune].to_s[0..138]
           combo = @server.get_combined
           puts "Hourly update"
           puts "Tweet @ #{now}: #{fortune}"
           puts "Tweet @ #{now}: #{combo}"
           Twitter.update(fortune)
           Twitter.update(combo)
       end
    end
end

# Start main loop
bot = PequenoTweeter.new
bot.start
