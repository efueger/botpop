#encoding: utf-8

# module BotpopPlugins
#   module MyFuryPlugin

#     MATCH = lambda do |parent|
#       parent.on :message, /!whatkingofanimal.*/ do |m| BotpopPlugins::exec_whatkingofanimal m end
#     end

#     HELP = ["!whatkingofanimal", "!animallist", "!checkanimal [type]"]

#     def self.exec_whatkingofanimal m
#       m.reply "Die you son of a" + ["lion", "pig", "red panda"].shuffle.first + " !!"
#     end

#   end
# end
