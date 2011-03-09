$:.unshift File.join(File.dirname(__FILE__), "..", "lib")
$:.unshift File.join(File.dirname(__FILE__), "..", "example")

require 'unified2'
require 'mongodb'
require 'pp'

MongodbAdaptor.connect

# Unified2 Configuration
Unified2.configuration do
  # Sensor Configurations
  sensor :interface => 'en1'

  # Load signatures, generators & classifications into memory
  load :signatures, 'seeds/sid-msg.map'
  load :generators, 'seeds/gen-msg.map'
  load :classifications, 'seeds/classification.config'
end

@sensor, start_at = MongodbAdaptor.find_sensor

Unified2.watch('seeds/unified2', start_at) do |event|
  next if event.signature.blank? || event.payload.blank?
  
  puts event

  @event = Event.create(
    {
      :event_id => event.id.to_i,
      :source_ip => event.source_ip.to_s,
      :destination_ip => event.destination_ip.to_s,
      :severity_id => event.severity.to_s,
      :sensor_id => @sensor.id
    }
  )

  @event.packet = Packet.new(
    {
      :length => event.payload.length,
      :payload => event.payload.hex
    }
  )

  @event.classification = Classification.new(
    {
      :name => event.classification.name,
      :short => event.classification.short,
      :classification_id => event.classification.id
    }
  )
  
  @event.signature = Signature.new(
    {
      :name => event.signature.name,
      :signature_id => event.signature.id,
      :generator_id => event.generator_id,
      :revision => event.signature.revision,
      :references => event.signature.references
    }
  )

  @sensor.events << @event
  @sensor.update_attributes(:last_event_id => @event.event_id)
end
