module Unified2
  
  class Packet < ::BinData::Record
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
  
end