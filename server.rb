#!/usr/bin/ruby

require 'open-uri'

module Server
  class Status
    def get_address
      open("http://myip.se") {|f|f.read.scan(/([0-9]{1,3}\.){3}[0-9]{1,3}/);return $~}
    end

    def get_users
      #users = `who -q`
      who = %x[who | awk '{print $1,$5}']
      userlines = who.split(/\n/)
      users = Array.new
      usersstring = ""
      userlines.each {|l| 
        if l =~ /(\w+).*\((.*)\:/
           users << { :user => $1, :ip => $2 }   
           usersstring += "#{$1}(#{$2}), "
        end
      }
      return usersstring
    end

    def get_combined
        ip = get_address.to_s[-7,7]
        if %x[uptime] =~ /.*up\s*(.*)/
            uptime = $1
        end
        return "..#{ip}, #{get_hemma_status}, #{uptime} "
    end

    def check_ip
        current = get_address.to_s
        filed = File.open('/var/cache/twitterbot/ip') {|f| f.readline}
        filed.chomp!
        if !current.eql? filed 
            File.open('/var/cache/twitterbot/ip','w') {|f| f.puts current}
            return "IP has changed! Old #{filed} new #{current}"
        end
        return "No IP change"
    end

    def get_top_process
        top = %x[ps -eo pcpu,pid,user,args | sort -r -k1 | head -3]
        lines = top.split(/\n/)
        return lines[1]
    end

    def get_hemma_status
        tdtool = %x[tdtool --list | cut -f3]
        lines = tdtool.split(/\n/)
        units = ""
        lines.each {|l|
            if l =~ /OFF/
                units << [0x2581].pack("U")
            elsif l =~ /ON/
                units << [0x2588].pack("U") 
            end
        }
        return units
    end

    def get_last_boot
      last = `who -b`
      if last =~ /.*system boot\s*(.*)/
          return "#{$1}"
      end
      return "Unknown"
    end

    def get_uptime
        uptime = `uptime`
        if uptime =~ /\sup\s(.*),.*users.*/
            return "#{$1}h"
        end
        return "Unknown"
    end
  end
end

public
def test
status = Server::Status.new
puts "Current external IP: #{status.get_address}"
puts "Active users: #{status.get_users}"
puts "Last reboot whas: #{status.get_last_boot}"
puts "Current uptime is: #{status.get_uptime}"
puts "Top CPU user: #{status.get_top_process}"
puts "Hemma status: #{status.get_hemma_status}"
puts "IP check: #{status.check_ip}"
puts "Combo: #{status.get_combined}"
end

