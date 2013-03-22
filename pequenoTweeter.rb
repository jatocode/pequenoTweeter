#!/usr/bin/env ruby
require 'rubygems'
require 'chatterbot/dsl'
require './server.rb'
#gem 'twitter','2.1.0' # Since I'm mixing chatterbot and twitter I need to do this
require "twitter"
require 'faraday'
require 'typhoeus'
require 'typhoeus/adapters/faraday'

# PequenoTweeter 

class PequenoTweeter
    def start
        exclude "http://"
        blacklist "mean_user, private_user"

        puts "Starting pequenoTweeter. Waiting for replies.."

        begin
        loop do
          shutdown = false
          puts "Checking for replies"
          replies do |tweet|

            puts "Found #{replies.length} replies"

            text = tweet[:text] 
            puts "#{tweet[:user][:name]}: #{text}"

            answer = case text.downcase! 
               when /address/ then "You'll find me at: #{@server.get_address}"
               when /uptime/  then "Been up since #{@server.get_uptime}"
               when /users/   then "My active users are: #{@server.get_users}"
               when /boot/    then "My last reboot was #{@server.get_last_boot}"
               when /top/     then "Top process: #{@server.get_top_process}"
               when /hemma/   then "Status: #{@server.get_hemma_status}"
               when /ping/    then "Pong!"
               when /#{@shutdown_cmd}/ then "Shutting down!"
               else "" 
            end
            unless answer == "" 
                puts "#{Time.now} : #{answer}"
                # send it back!
                reply "#USER# #{answer}", tweet
            end

            if text =~ /#{@shutdown_cmd}/ 
              puts "Exiting!"
              shutdown = true
          end

          end
          update_config # I can't remember why I need to do this?
          check_ip_change
          hourly_update
          sleep 61
          exit if shutdown==true # After sleep to allow reply to be sent

          end
          rescue Twitter::Error::TooManyRequests => error
            puts "Rate limit exceeded: #{error}, sleeping for #{error.rate_limit.reset_in}"
            sleep error.rate_limit.reset_in
            retry
          rescue
            puts "Something went wrong. Retrying. #{$!}"
            sleep 3
            retry
        end
    end

    def initialize
        # Load config
        @my_config = YAML.load_file('pequenoTweeter.yml')


# I had to add this to resolve an "end of filei reached" problem 
        middleware = Proc.new do |builder|
            builder.use Twitter::Request::MultipartWithFile
            builder.use Faraday::Request::Multipart
            builder.use Faraday::Request::UrlEncoded
            builder.use Twitter::Response::RaiseError, Twitter::Error::ClientError
            builder.use Twitter::Response::ParseJson
            builder.use Twitter::Response::RaiseError, Twitter::Error::ServerError
            builder.adapter :typhoeus
        end

        Twitter.middleware = Faraday::Builder.new(&middleware)

        # Configure twitter gem
        Twitter.configure do |config|
          config.consumer_key = @my_config[:consumer_key]
          config.consumer_secret = @my_config[:consumer_secret]
          config.oauth_token = @my_config[:token]
          config.oauth_token_secret = @my_config[:secret]
        end

        @server = Server::Status.new
        @shutdown_cmd = @my_config[:shutdown_cmd]
    end

    def check_ip_change
        ip = @server.check_ip
        unless ip =~ /No/
            Twitter.direct_message_create("datakille", ip)
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
