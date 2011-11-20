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

path = 'seeds/unified2-current.log'
#path = '/var/log/snort/merged.log'

Unified2.watch(path, :first) do |event|
  
  #puts event.source_ip
  #puts event.destination_ip

  #puts event.severity

  #puts event.classification.name

  #puts event.signature.name

  #event.extras.each do |extra|
    #puts extra.name
    #puts extra.value
  #end

  event.packets.each do |packet|

    #packet.to_pcap

    #packet.to_file('output.pcap', 'a')

    #puts packet.ip_header

    #puts packet.protocol.header

    puts packet.hexdump(:header => false, :width => 40)
  end

end
