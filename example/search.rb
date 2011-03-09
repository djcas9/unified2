$:.unshift File.join(File.dirname(__FILE__), "..", "lib")
$:.unshift File.join(File.dirname(__FILE__), "..", "example")

require 'unified2'
require 'mongodb'
require 'mongoid'
require 'hexdump'
require 'pp'

MongodbAdaptor.connect

@sensor = Sensor.last

puts @sensor.hostname

@sensor.events.each do |event|
  data = [event.packet.payload].first.pack('H*')
  Hexdump.dump(data.to_s, :width => 30)
end

# Sensor.all.each do |sensor|
#   puts sensor.hostname
# end