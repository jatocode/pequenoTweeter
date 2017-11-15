#!/usr/bin/env ruby
gem 'twitter', '>5.11.0'
require 'twitter'
require './server2.rb'

def hourly_update(client)
    base_path = '/var/cache/pequenoTweeter/'
    last_tweet = File.open("#{base_path}/last_tweet") {|f| f.readline}
    last_update = Time.at(last_tweet.to_i)

    now = Time.new
    if now-last_update > 3600 
        puts "Time for hourly update"
        File.open("#{base_path}/last_tweet",'w') {|f| f.puts now.to_i}
      #  fortune = %x[fortune].to_s[0..138]
        combo = @server.get_combined2
        puts "Tweet @ #{now}: #{combo}"
        begin
        client.update(combo)
        client.update(@oneliners.sample)
        rescue
            puts "Unable to tweet for some reason"
        end
    end
end


# Random oneliner
@oneliners = Array.new
File.foreach("1liners.txt", "\.\r") do |paragraph|
     @oneliners << paragraph.chomp
end

@server = Server::Status.new
config = {
    consumer_key: 'G92IHo6SKKhdnivIlMul2Q',
    consumer_secret: 'cSFivZb6Ez9tTxaoPqTrrwO2WpcJLMDPd5rUom25U',
    access_token: '490348314-UCKERC11iZHVnnCthVcvZBO72EF3z9jn4jVRPC1D',
    access_token_secret: '2jQJc8PIAb6VWBQWVQKRxliG0o0fhNWNI4ViINZVV4' 
}

rClient = Twitter::REST::Client.new config
sClient = Twitter::Streaming::Client.new config
puts "Starting twitter bot"
while true
    begin
#        sClient.user do |object|
#            case object
#            when Twitter::Tweet
#                if object.reply?
#                    puts "#{object.text}"
#                    rClient.update("@#{object.user.screen_name} Is that so?", in_reply_to_status_id:object.id)
#                end
#            when Twitter::DirectMessage
#                puts "It's a direct message!"
#            when Twitter::Streaming::StallWarning
#                warn "Falling behind!"
#            end
#        end
        ip = @server.check_ip
        unless ip.empty?
            rClient.create_direct_message("datakille", ip)
        end

        hourly_update(rClient)
        sleep 30
    end
end

