require 'irb/completion'
require 'bundler'
require 'pp'
require 'wirble'
require 'open-uri'
require 'json'

# syntax color:
Wirble.init
Wirble.colorize

IRB.conf[:AUTO_INDENT] = true
IRB.conf[:USE_READLINE] = true

puts 'Configuration file loaded!...'
