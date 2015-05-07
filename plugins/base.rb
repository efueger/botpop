#encoding: utf-8

module BotpopPlugins
  module Base

    MATCH = lambda do |parent, plugin|
      parent.on :message, /!troll .+/ do |m| plugin.exec_troll m end
      parent.on :message, "!version" do |m| plugin.exec_version m end
      parent.on :message, "!code" do |m| plugin.exec_code m end
      parent.on :message, "!cmds" do |m| plugin.exec_help m end
      parent.on :message, "!help" do |m| plugin.exec_help m end
    end

    # This is the most creepy and ugly method ever see
    def self.help m
      m.reply "!cmds, !help, !version, !code, !dos [ip], !fok [nick], !ping, !ping [ip], !trace [ip], !poke [nick], !troll [msg], !intra, !intra [on/off], #{Botpop::SEARCH_ENGINES_HELP}"
    end

    def self.exec_version m
      m.reply Botpop::VERSION
    end

    def self.exec_code m
      m.reply "https://github.com/pouleta/botpop"
    end

    def self.exec_help m
      help m
    end

    def self.exec_troll m
      # hours = (Time.now.to_i - Time.gm(2015, 04, 27, 9).to_i) / 60 / 60
      s = get_msg m
      url = "http://www.fuck-you-internet.com/delivery.php?text=#{s}"
      m.reply url
    end

  end
end
