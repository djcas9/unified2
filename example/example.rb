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

  #position 'seeds/position'
end

#path = 'seeds/unified2-current.log'
path = "/var/log/snort/merged.log.*"

Unified2.on_file_change = Proc.new do
  puts "HELLO"
end

Unified2.glob(path, {
  :timestamp => 0,
  :position => 0,
  :event_id => 0
}) do |event|
  puts event.id
end
