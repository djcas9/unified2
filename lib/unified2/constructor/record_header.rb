#
# Unified2
#
module Unified2

  #
  # Constructor
  #
  module Constructor

    #
    # Unified2 Header
    #
    class RecordHeader < ::BinData::Record

      endian :big

      uint32 :u2type

      uint32 :u2length
      
    end # class RecordHeader

  end # module Constructor

end # module Unified2
