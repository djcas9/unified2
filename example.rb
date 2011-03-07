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

class RecordHeader < BinData::Record
  endian :big

  uint32 :u2type
  uint32 :u2length
end

class Event < BinData::Record
  endian :big

  uint32 :sensor_id
  uint32 :event_id
  uint32 :event_second
  uint32 :event_microsecond
  uint32 :signature_id
  uint32 :generator_id
  uint32 :signature_revision
  uint32 :classification_id
  uint32 :priority_id
  ipv4   :ip_source
  ipv4   :ip_destination
  uint16 :sport_itype
  uint16 :dport_icode
  uint8  :protocol
  uint8  :packet_action
end

class Event6 < BinData::Record
  endian :big

  uint32  :sensor_id
  uint32  :event_id
  uint32  :event_second
  uint32  :event_microsecond
  uint32  :signature_id
  uint32  :generator_id
  uint32  :signature_revision
  uint32  :classification_id
  uint32  :priority_id
  uint128 :ip_source
  uint128 :ip_destination
  uint16  :sport_itype
  uint16  :dport_icode
  uint8   :protocol
  uint8   :packet_action
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
io = File.open('unified2-example')

count = 0
source_addresses = []
destination_addresses = []
until io.eof?
  event = Unified2.read(io)

  pp event
  
  exit -1
  
  # if event.data.respond_to?(:ip_source)
  #   #next if source_addresses.include?(event.data.ip_source)
  #   
  #   pp "Event: #{event.data.event_id} - S => #{event.data.ip_source} | D => #{event.data.ip_destination}"
  #   source_addresses.push event.data.ip_source
  # end

  #count += 1
  # exit -1 if count >= 10
end