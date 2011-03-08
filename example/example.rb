$:.unshift File.join(File.dirname(__FILE__), "..", "lib")
require 'unified2'
require 'pp'

# Plugin Configurations
# Load signatures into memory
Unified2.configuration do
  
  #:mysql,:postgresql,:sguil,:snorby
  plugin :mongodb, :username => 'root', :password => 'password',
    :host => 'localhost'

  load 'sid-msg.map'
  load 'sid-msg.map'
end

# Unified2#watch will continuously monitor
# the unified output for modifications and
# process the data accordingly.

Unified2.watch('unified2', :start => 451) do |event|
 puts "#{event.id} | #{event.ip_destination} | #{event.ip_source} | #{event.signature.name}"
end

# Unified2#read will parse the supplied
# unified2 output and return records untill EOF.

# @signatures = []
# 
# Unified2.read('/var/log/snort/merged.log', :limit => 5000) do |event|
#   next if @signatures.include?(event.signature.id)
#   @signatures.push event.signature.id
#   
#   puts "#{event.id} | #{event.ip_destination} | #{event.ip_source} | #{event.signature.name}"
#   
# end
