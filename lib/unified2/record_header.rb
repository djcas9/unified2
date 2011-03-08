module Unified2
  
  class RecordHeader < ::BinData::Record
    endian :big

    uint32 :u2type
    uint32 :u2length
  end
  
end