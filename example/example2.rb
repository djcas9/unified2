$:<< '../lib' << 'lib'

require 'unified2'

# Unified2 Configuration
Unified2.configuration do

  # Sensor Configurations
  sensor :interface => 'en1',
    :name => 'Unified2 Example', :id => 3

  # Load signatures, generate events will be sent over the web socket
  # quickly so we slow down the process of
  # pushing events onto the channel.rs & classifications into memory
  load :signatures, 'seeds/sid-msg.map'

  load :generators, 'seeds/gen-msg.map'
  
  load :classifications, 'seeds/classification.config'

end

Unified2.watch('seeds/unified2-current.log', :first) do |event|
  puts event.id if event.id % 100
end
