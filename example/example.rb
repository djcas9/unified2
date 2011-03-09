$:.unshift File.join(File.dirname(__FILE__), "..", "lib")
require 'unified2'
require 'pp'

# Unified2 Configuration
Unified2.configuration do
  # # Sensor Configurations
  sensor :id => 200, :name => 'Hello Sensor', :interface => 'en1'
  
  # Load signatures, generators & classifications into memory
  load :signatures, '/Users/mephux/.snort/etc/sid-msg.map'
  load :generators, '/Users/mephux/.snort/etc/gen-msg.map'
  load :classifications, '/Users/mephux/.snort/etc/classification.config'
end

# Unified2#watch will continuously monitor
# the unified output for modifications and
# process the data accordingly.

Unified2.watch('/var/log/snort/merged.log', 1) do |event|
  next if event.signature.blank?

  puts event.signature.name

  # puts "#{event.sensor.name} #{event.timestamp} || #{event.source_port} #{event.destination_port} | #{event.protocol}"
  
  # #{event.source_port} #{event.destination_port}
  # puts "#{event.id} | #{event.ip_destination} | #{event.ip_source} | #{event.signature.name}"
  # {event.generator_id} || #{event.signature.id}
end

# Unified2#read will parse the supplied
# unified2 output and return records untill EOF.

# @signatures = []
# Unified2.watch('/var/log/snort/merged.log', 101) do |event|
#   next if event.signature.name.blank?
#   next if @signatures.include?(event.signature.id)
#   
#   @signatures.push event.signature.id
#   
#   puts "#{event.id} | #{event.ip_destination} | #{event.ip_source} | #{event.signature.name}"
# end
