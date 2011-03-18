module Unified2
  
  module Constructor
    #
    # Event Packet
    #
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
      
    end # class Packet
    
  end # module Constructor
  
end # module Unified2