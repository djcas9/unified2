$:.unshift File.join(File.dirname(__FILE__), "..", "lib")
$:.unshift File.join(File.dirname(__FILE__), "..", "example")

require 'unified2'
require 'mongodb'
require 'mongoid'
require 'hexdump'
require 'pp'

MongodbAdaptor.connect

@sensor = Sensor.last

# Sensor.all.each do |sensor|
#   puts sensor.hostname
# end

@sensor.events.each do |event|
  
  puts event.event_id
  puts "#{event.source_ip}:#{event.source_port}"
  puts "#{event.destination_ip}:#{event.destination_port}"
  puts "\n"
  puts event.signature.name
  puts event.classification.name
  
  # etc...
  
  # Output Event Payload
  data = [event.packet.payload].first.pack('H*')
  Hexdump.dump(data.to_s, :width => 30)
end