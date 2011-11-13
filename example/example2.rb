$:.unshift File.join(File.dirname(__FILE__), "..", "lib")
require 'unified2'

# Unified2 Configuration
Unified2.configuration do

  # Sensor Configurations
  sensor :interface => 'en1',
    :name => 'Unified2 Example', :id => 3

  # Load signatures, generate events will be sent over the web socket
  # quickly so we slow down the process of
  # pushing events onto the channel.rs & classifications into memory
  load :signatures, '/Users/mephux/.snort-2.9.1.2/etc/sid-msg.map'

  load :generators, '/Users/mephux/.snort-2.9.1.2/etc/gen-msg.map'
  
  load :classifications, '/Users/mephux/.snort-2.9.1.2/etc/classification.config'

end

#path = 'seeds/unified2.log'
path = '/var/log/snort/merged.log'

Unified2.watch(path, 763243) do |event|
  #next if event.signature.blank?
  #next unless event.packets.count >= 3

  #next if event.extras.empty?

  #next unless event.classification.name == "Potentially Bad Traffic"

  #next unless event.packets.map(&:checksum).include?('2ee50451de0fb4136e0e66d4f9ebdf49')

  puts event.id

  #event.extras.each do |extra|
    #puts extra.name + " == " + extra.value
    #puts "\n\n"
  #end

  #exit 1

  #p event.packets.count

  event.packets.each do |packet|
    #p packet.ip_header
    #puts packet.protocol.header
    #puts packet.test
    #puts packet
    #puts packet.hex
    #puts packet.checksum
    #puts packet.hexdump(:header => false, :width => 40)
  end

  # exit 1
  #puts event.packets.length

  #puts event.signature
  #puts event.classification.name
  #puts event.severity
  #puts event.protocol.to_h

  #puts event.source_ip


  #exit 1 if event.protocol.tcp?
end


