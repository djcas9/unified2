$:.unshift File.join(File.dirname(__FILE__), "..", "lib")
$:.unshift File.join(File.dirname(__FILE__), "..", "example")

require 'unified2'
require 'connect'
require 'pp'

# Initialize Database Connection 
Connect.setup

# Unified2 Configuration
Unified2.configuration do
  
  # Sensor Configurations
  sensor :interface => 'en1', :name => 'Example Sensor'

  # Load signatures, generators & classifications into memory
  load :signatures, 'seeds/d'
  load :generators, 'seeds/gen-msg.map'
  load :classifications, 'seeds/classification.config'
  
end

# Locate the sensor in the database using
# the hostname and interface. If this fails
# rUnified2 will create a new sensor record.
sensor = Sensor.find(Unified2.sensor)
Unified2.sensor.id = sensor.id

# Load the classifications, generators &
# signatures into the database and store the 
# md5 in the sensor record. This will only
# update if the md5s DO NOT match.
[[Classification,:classifications], [Signature, :signatures], [Signature, :generators]].each do |klass, method|
  unless sensor.send(:"#{method}_md5") == Unified2.send(method).send(:md5)
    klass.send(:import,  { method => Unified2.send(method).send(:data), :force => true })
    sensor.update(:"#{method}_md5" => Unified2.send(method).send(:md5))
  end
end

# Monitor the unfied2 log and process the data.
# The second argument is the last event processed by
# the sensor. If the last_event_id column is blank in the
# sensor table it will begin at the first available event.
Unified2.watch('/var/log/snort/merged.log', sensor.last_event_id + 1 || :first) do |event|
  next if event.signature.blank?

  puts event

  insert_event = Event.new({
                       :event_id => event.id,
                       :uid => event.uid,
                       :created_at => event.timestamp,
                       :sensor_id => event.sensor.id,
                       :source_ip => event.source_ip,
                       :source_port => event.source_port,
                       :destination_ip => event.destination_ip,
                       :destination_port => event.destination_port,
                       :severity_id => event.severity,
                       :protocol => event.protocol,
                       :link_type => event.payload.linktype,
                       :packet_length => event.payload.length,
                       :packet => event.payload.hex,
                       :classification_id => event.classification.id,
                       :signature_id => event.signature.id
  })

  if insert_event.save
    insert_event.update_sensor
  else
    STDERR.puts "VALIDATION ERROR OR RECORD ALREADY EXISTS #{insert_event.errors}"
  end

end
