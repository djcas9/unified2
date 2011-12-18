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

  load :references, 'seeds/reference.config'

end

path = "/var/log/snort/merged.log.*"
#path = "/var/log/snort/merged.log.*"
#path = "/Users/mephux/Downloads/snort.u2.*"

Unified2.glob(path, { 
  :timestamp => 0, 
  :position => 0, 
  :position => 0 
}) do |event|
  next unless event.tcp?
  puts event.to_h

  exit 1

  event.packets.each do |packet|
    p packet.protocol.header
  end
end
