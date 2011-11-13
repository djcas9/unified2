$:<< '../lib' << 'lib'

require 'unified2'

# Unified2 Configuration
Unified2.configuration do

  # Sensor Configurations
  sensor :interface => 'en1',
    :name => 'Unified2 Example', :id => 3

  load :signatures, 'seeds/sid-msg.map'

  load :generators, 'seeds/gen-msg.map'
  
  load :classifications, 'seeds/classification.config'

end

Unified2.watch('seeds/unified2-current.log', :first) do |event|

  puts event.id

  puts event.severity

  puts event.classification.name

  puts event.signature.name

  event.extras.each do |extra|
    puts extra.name
    puts extra.value
  end

  event.packets.each do |packet|
    puts packet.ip_header
    puts packet.protocol.header
    puts packet.hexdump(:header => false, :width => 40)
  end

end

