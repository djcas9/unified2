$:.unshift File.dirname(__FILE__) + "/lib"
require 'unified2'
require 'pp'

# Plugin Configurations
# Load signatures into memory
Unified2.configuration do
  #:mysql,:postgresql,:sguil,:snorby
  plugin :mongodb, :username => 'root', :password => 'password',
    :host => 'localhost'

  load 'sid-msg.map'
  load 'sid-msg.map'
end

# Unified2#watch will continuously monitor
# the unified output for modifications and
# process the data accordingly.

# #Unified2.watch('unified2-example') do |event|
#  pp event.event_id
#end

# Unified2#read will parse the supplied
# unified2 output and return records untill EOF.

Unified2.read('unified2-example', :limit => 5000) do |event|
  
  puts "#{event.id} | #{event.ip_destination} | #{event.ip_source} | #{event.signature}"
  
end



# OLD

# if event.data.respond_to?(:signature_id)
#
#   @events[id] = {
#     :ip_destination => event.data.ip_destination,
#     :priority_id => event.data.priority_id,
#     :signature_revision => event.data.signature_revision,
#     :event_id => event.data.event_id,
#     :protocol => event.data.protocol,
#     :sport_itype => event.data.sport_itype,
#     :event_second => event.data.event_second,
#     :packet_action => event.data.packet_action,
#     :dport_icode => event.data.dport_icode,
#     :sensor_id => event.data.sensor_id,
#     :classification_id => event.data.classification_id,
#     :generator_id => event.data.generator_id,
#     :ip_source => event.data.ip_source,
#     :event_microsecond => event.data.event_microsecond
#   }
#
#   if @rules.has_key?(event.data.signature_id.to_s)
#     sig = @rules[event.data.signature_id.to_s]
#
#     @events[id][:signature] = {
#       :signature_id => event.data.signature_id,
#       :name => sig[:name],
#       :references => sig[:references]
#     }
#   else
#     @events[id][:signature_id] = event.data.signature_id
#   end
# end
#
# if event.data.respond_to?(:packet_data)
#   @events[id][:packet] = {
#     :linktype => event.data.linktype,
#     :packet_microsecond => event.data.packet_microsecond,
#     :packet_second => event.data.packet_second,
#     :data => event.data.packet_data.to_s.unpack('H*'),
#     :event_second => event.data.event_second,
#     :packet_length => event.data.packet_length
#   }
# end
