$:.unshift File.join(File.dirname(__FILE__), "..", "lib")
$:.unshift File.join(File.dirname(__FILE__), "..", "example")

require 'unified2'
require 'connect'
require 'pp'

Connect.setup

@sensor = Sensor.first

@sensor.events.each do |event|
  puts event.signature.name
end