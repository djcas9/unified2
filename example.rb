#!/usr/bin/env ruby
# http://cvs.snort.org/viewcvs.cgi/snort/src/output-plugins/spo_unified2.c?rev=1.3&content-type=text/vnd.viewcvs-markup

require 'rubygems'
require 'bindata'

class IPV4 < BinData::Primitive
  array :octets, :type => :uint8, :initial_length => 4

  def set(val)
    ints = val.split(/\./).collect { |int| int.to_i }
    self.octets = ints
  end

  def get
    self.octets.collect { |octet| "%d" % octet }.join(".")
  end

end

# class Signature < BinData::Primitive
#
#   uint32be :signature_id
#   stringz :signature_name
#   array :references, :type => :uint8, :initial_value => []
#
#   def set(signature_id)
#     self.signature_id = signature_id
#     self.signature_name = 'TEST'
#     self.references = [1,2]
#   end
#
#   def get
#     self.signature_id
#   end
# end

class RecordHeader < BinData::Record
  endian :big

  uint32 :u2type
  uint32 :u2length
end

class Event < BinData::Record
  endian :big

  uint32    :sensor_id
  uint32    :event_id
  uint32    :event_second
  uint32    :event_microsecond
  uint32    :signature_id
  uint32    :generator_id
  uint32    :signature_revision
  uint32    :classification_id
  uint32    :priority_id
  ipv4      :ip_source
  ipv4      :ip_destination
  uint16    :sport_itype
  uint16    :dport_icode
  uint8     :protocol
  uint8     :packet_action
end

class Event6 < BinData::Record
  endian :big

  uint32    :sensor_id
  uint32    :event_id
  uint32    :event_second
  uint32    :event_microsecond
  uint32    :signature_id
  uint32    :generator_id
  uint32    :signature_revision
  uint32    :classification_id
  uint32    :priority_id
  uint128   :ip_source
  uint128   :ip_destination
  uint16    :sport_itype
  uint16    :dport_icode
  uint8     :protocol
  uint8     :packet_action
end

class Packet < BinData::Record
  endian :big

  uint32 :sensor_id
  uint32 :event_id
  uint32 :event_second
  uint32 :packet_second
  uint32 :packet_microsecond
  uint32 :linktype
  uint32 :packet_length
  string :packet_data, :read_length => :packet_length
end

class Unified2 < BinData::Record
  record_header :header

  choice :data, :selection => :type_selection do
    packet "packet"
    event  "ev4"
    event6 "ev6"
  end

  string :read_length => :padding_length  # padding

  #define UNIFIED2_EVENT 1
  #define UNIFIED2_PACKET 2
  #define UNIFIED2_IDS_EVENT 7
  #define UNIFIED2_EVENT_EXTENDED 66
  #define UNIFIED2_PERFORMANCE 67
  #define UNIFIED2_PORTSCAN 68
  #define UNIFIED2_IDS_EVENT_IPV6 72
  def type_selection
    case header.u2type
    when 2
      "packet"
    when 7
      "ev4"
    when 72
      "ev6"
    else
      "unknown type #{header.u2type}"
    end
  end

  # sometimes the data needs extra padding
  def padding_length
    if header.u2length > data.num_bytes
      header.u2length - data.num_bytes
    else
      0
    end
  end
end

require 'pp'

# Load Signatures Into Memory
file ||= File.open('sid-msg.map')
@rules = {}
count = 0

file.each_line do |line|
  id, body, *references = line.split(' || ')
  @rules[id] = {
    :id => id,
    :name => body,
    :references => references
  }
end

io = File.open('unified2-example')

@events = {}

until io.eof?
  event = Unified2.read(io)
  id = event.data.event_id.to_s
  
  if event.data.respond_to?(:signature_id)
    
    @events[id] = {
      :ip_destination => event.data.ip_destination,
      :priority_id => event.data.priority_id,
      :signature_revision => event.data.signature_revision,
      :event_id => event.data.event_id,
      :protocol => event.data.protocol,
      :sport_itype => event.data.sport_itype,
      :event_second => event.data.event_second,
      :packet_action => event.data.packet_action,
      :dport_icode => event.data.dport_icode,
      :sensor_id => event.data.sensor_id,
      :classification_id => event.data.classification_id,
      :generator_id => event.data.generator_id,
      :ip_source => event.data.ip_source,
      :event_microsecond => event.data.event_microsecond
    }

    if @rules.has_key?(event.data.signature_id.to_s)
      sig = @rules[event.data.signature_id.to_s]
      
      @events[id][:signature] = {
        :signature_id => event.data.signature_id,
        :name => sig[:name],
        :references => sig[:references]
      }
    else
      @events[id][:signature_id] = event.data.signature_id
    end
  end

  if event.data.respond_to?(:packet_data)
    @events[id][:packet] = {
      :linktype => event.data.linktype,
      :packet_microsecond => event.data.packet_microsecond,
      :packet_second => event.data.packet_second,
      :data => event.data.packet_data,
      :event_second => event.data.event_second,
      :packet_length => event.data.packet_length
    }
  end

  #
  # sig = nil
  #
  # if event.data.respond_to?(:signature_id)
  #   if @rules.has_key?(event.data.signature_id.to_s)
  #     sig = @rules[event.data.signature_id.to_s]
  #   end
  # end
  #
  # #pp event
  # if sig
  #   sig = sig[:name]
  #   next if signatures.include?(sig)
  #
  #   signatures.push sig
  #   puts "#{event.data.signature_id} => #{sig}"
  # end


  # if event.data.respond_to?(:ip_source)
  #   #next if source_addresses.include?(event.data.ip_source)
  #
  #   pp "Event: #{event.data.event_id} - S => #{event.data.ip_source} | D => #{event.data.ip_destination}"
  #   source_addresses.push event.data.ip_source
  # end


  count += 1
  if count >= 10 # => 5
    pp @events["5"]
    exit -1
  end
end
