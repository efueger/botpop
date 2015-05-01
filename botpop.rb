#!/usr/bin/env ruby
#encoding: utf-8

require 'cinch'
require 'uri'
require 'net/ping'
require 'pry'
# require 'yaml'

VERSION = "0.2"

SEARCH_ENGINES = {
  "ddg" => "https://duckduckgo.com/?q=___MSG___",
  "yt" => "https://www.youtube.com/results?search_query=___MSG___",
  "yp" => "https://www.youporn.com/search/?query=___MSG___",
  "gh" => "https://github.com/search?q=___MSG___&type=Code&utf8=%E2%9C%93",
  "w" => "https://en.wikipedia.org/wiki/Special:Search?&go=Go&search=___MSG___",
  "wfr" => "https://fr.wikipedia.org/wiki/Special:Search?search=___MSG___&go=Go",
  "tek" => "https://intra.epitech.eu/user/___MSG___",
  "archfr" => "https://wiki.archlinux.fr/index.php?title=Sp%C3%A9cial%3ARecherche&search=___MSG___",
  "arch" => "https://wiki.archlinux.org/index.php?title=Special%3ASearch&search=___MSG___&go=Go",
  "gl" => "https://gitlab.com/search?utf8=%E2%9C%93&search=___MSG___&group_id=&repository_ref=",
  "map" => "https://www.google.fr/maps/search/___MSG___/",
  "actu" => "https://www.google.fr/search?hl=fr&gl=fr&tbm=nws&authuser=0&q=___MSG___",
  "news" => "https://www.google.fr/search?hl=fr&gl=fr&tbm=nws&authuser=0&q=___MSG___",
  "tw" => "https://twitter.com/search?q=___MSG___"
}

SEARCH_ENGINES_VALUES = SEARCH_ENGINES.values.map{|e|"!"+e}.join(', ')
SEARCH_ENGINES_KEYS = SEARCH_ENGINES.keys.map{|e|"!"+e}.join(', ')
TARGET = /[[:alnum:]_\-\.]+/

def get_msg m
  URI.encode(m.params[1..-1].join(' ').gsub(/\![^ ]+ /, ''))
end

def get_ip m
  m.params[1..-1].join(' ').gsub(/\![^ ]+ /, '').gsub(/[^[:alnum:]\-\_\.]/, '')
end

def help m
  m.reply "!cmds, !help, !version, !ddos [ip], !ping, !ping [ip], !code, !intra, !intra [on/off], #{SEARCH_ENGINES_KEYS}"
end

bot = Cinch::Bot.new do
  configure do |c|
    if ARGV[0] == "pathwar"
      c.server = "irc.pathwar.net"
      c.channels = ["#pathwar-fr"]
    else
      c.server = "irc.freenode.org"
      c.port = 7000
      if ARGV[0] == "debug"
        c.channels = ["#equilibres"]
      else
        c.channels = ["#equilibre"]
      end
      c.ssl.use = true
    end

    c.user = "cotcot"
    c.nick = "cotcot"
  end

#  on :message, "!status" do |m|
#    hours = (Time.now.to_i - Time.gm(2015, 04, 27, 9).to_i) / 60 / 60
#    url = "http://www.fuck-you-internet.com/delivery.php?text=#{hours}h%20apr%C3%A8s%20le%20d%C3%A9but%20du%20pathwar"
#    m.reply url
#  end

  on :message, /\!(#{SEARCH_ENGINES.keys.join('|')}) .+/ do |m|
    msg = get_msg m
    url = SEARCH_ENGINES[m.params[1..-1].join(' ').gsub(/\!([^ ]+) .+/, '\1')]
    url = url.gsub('___MSG___', msg)
    m.reply url
  end

  on :message, "!version" do |m|
    m.reply VERSION
  end

  on :message, "!code" do |m|
    m.reply "https://github.com/pouleta/botpop"
  end

  on :message, "!intra" do |m|
    m.reply Net::Ping::External.new("intra.epitech.eu").ping? ? "Intra ok" : "Intra down"
  end

  on :message, "!intra on" do |m|
    @intra ||= Mutex.new
    if @intra.try_lock
      begin
        m.reply "INTRANET SPY ON"
        @intra_on = true
        sleep 1
        loop do
          break if @intra_on == false
          m.reply Net::Ping::External.new("intra.epitech.eu").ping? ? "Intra ok" : "Intra down"
          sleep 3
        end
        @intra.unlock
      rescue
        @intra.unlock
      end
    else
      m.reply "INTRA SPY ALREADY ON"
    end
  end

  on :message, "!intra off" do |m|
    @intra_on = false
    m.reply "INTRA SPY OFF"
  end

  on :message, "!ping" do |m|
    m.reply "#{m.user} pong"
  end

  on :message, /!ping #{TARGET}\Z/ do |m|
    ip = get_ip m
    p = Net::Ping::External.new ip
    str = "failed"
    if p.ping?
      str = "#{(p.duration*100.0).round 2}ms (#{p.host})"
    end
    m.reply "#{ip} ping> #{str}"
  end

  on :message, /!ddos #{TARGET}\Z/ do |m|
    @ddos ||= Mutex.new
    if @ddos.try_lock
      begin
        ip = get_ip m
        m.reply "Begin attack against #{ip}"
        s = `timeout 1s hping --flood '#{ip}' 2>&1`
        s = s.split("\n")[3].to_s
        m.reply (Net::Ping::External.new(ip).ping? ? "failed :(" : "down !!!") + " " + s
        @ddos.unlock
      rescue
        @ddos.unlock
      end
    else
      m.reply "Wait for the end of the last ddos"
    end
  end

  on :message, /!trace #{TARGET}\Z/ do |m|
    @trace ||= Mutex.new
    if @trace.try_lock
      begin
        ip = get_ip m
        m.reply "It can take time"
        s = `tracepath '#{ip}'`.to_s.split("\n")
        binding.pry
        if s.include? {|e| e.include? "Too many hops" }
          m.reply "Cannot reach the host"
        end
        so = s.select{|e| not e.include? "no reply" and e =~ /\A \d+: .+/}
        binding.pry
        @trace.unlock
        s.each{|l| m.reply l; sleep 0.5}
      rescue # in error case
        @trace.unlock
      end
    else
      m.reply "Please retry after when the last trace end"
    end
  end

  on :message, "!cmds" do |m|
    help m
  end

  on :message, "!help" do |m|
    help m
  end

end

bot.start