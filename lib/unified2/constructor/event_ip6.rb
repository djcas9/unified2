module Unified2
  
  module Constructor
    
    #
    # Event IP Version 6
    #
    class EventIP6 < ::BinData::Record
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
      
    end # class EventIP6
    
  end # module Constructor
  
end # module Unified2