module Unified2
  
  module Constructor
    #
    # Event Packet
    #
    class ExtraData < ::BinData::Record
      
      endian :big

      uint32 :sensor_id
      
      uint32 :event_id
      
      uint32 :event_second
      
      uint32 :type
      
      uint32 :data_type
      
      uint32 :blob_length

      string :blob, :read_length => lambda { blob_length - 8 }
      
    end # class ExtraData
    
  end # module Constructor
  
end # module Unified2

