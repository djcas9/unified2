$:.unshift File.join(File.dirname(__FILE__), "..", "lib")
require 'unified2'

# Unified2 Configuration
Unified2.configuration do
  
  # Sensor Configurations
  sensor :interface => 'en1', :name => 'Example Sensor'

  # Load signatures, generators & classifications into memory
  load :signatures, 'seeds/sid-msg.map'
  
  load :generators, 'seeds/gen-msg.map'
  
  load :classifications, 'seeds/classification.config'
  
end

# Monitor the unfied2 log and process the data.
# The second argument is the last event processed by
# the sensor. If the last_event_id column is blank in the
# sensor table it will begin at the first available event.
Unified2.watch('seeds/unified2.log', :first) do |event|
  next if event.signature.blank?

  puts event

end