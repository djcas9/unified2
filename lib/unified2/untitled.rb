require 'mongoid'
require 'hexdump'

Mongoid.configure do |config|
  name = "unfied2_development"
  host = "localhost"
  config.master = Mongo::Connection.new.db(name)
  config.slaves = [
    Mongo::Connection.new(host, 27017, :slave_ok => true).db(name)
  ]
  config.persist_in_safe_mode = false
end

class Sensor
  include Mongoid::Document

  field :sensor_id, :type => Integer
  field :hostname, :type => String
  field :interface, :type => String
  field :last_event_id, :type => Integer
  references_many :events
end

class Event
  include Mongoid::Document

  field :event_id, :type => Integer
  field :sensor_id, :type => Integer
  field :severity_id, :type => Integer
  field :source_ip, :type => String
  field :destination_ip, :type => String

  embeds_one :signature
  embeds_one :packet
  embeds_one :classification
  referenced_in :sensor
end

class Signature
  include Mongoid::Document

  field :name, :type => String
  field :signature_id, :type => Integer
  field :generator_id, :type => Integer
  field :revision, :type => Integer
  field :name, :type => String
  field :references, :type => Array, :default => []
  
  embedded_in :event, :inverse_of => :signature
end

class Classification
  include Mongoid::Document

  field :name, :type => String
  field :short, :type => String
  field :classification_id, :type => Integer
  
  embedded_in :event, :inverse_of => :classification
end

class Packet
  include Mongoid::Document

  field :length, :type => Integer
  field :payload
  
  embedded_in :event, :inverse_of => :packet
end

@sensor = Sensor.last

puts @sensor.hostname

@sensor.events.each do |event|
  data = [event.packet.payload].first.pack('H*')
  Hexdump.dump(data.to_s, :width => 30)
end

# Sensor.all.each do |sensor|
#   puts sensor.hostname
# end