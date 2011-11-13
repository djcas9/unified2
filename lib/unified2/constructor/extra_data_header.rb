module Unified2

  module Constructor
    #
    # Extra Data Header
    # 
    class ExtraDataHeader < ::BinData::Record

      endian :big

      uint32 :event_type

      uint32 :event_length

    end # class ExtraDataHeader

  end # module Constructor

end # module Unified2


