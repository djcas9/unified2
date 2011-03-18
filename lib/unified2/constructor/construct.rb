require 'unified2/constructor/event_ip4'
require 'unified2/constructor/event_ip6'
require 'unified2/constructor/record_header'
require 'unified2/constructor/packet'

module Unified2
  
  module Constructor
    
    class Construct < ::BinData::Record

      #
      # Rename record_header to header
      # to simplify and cut down on verbosity
      # 
      record_header :header

      # 
      # Unified2 data types
      # 
      # Currently rUnified2 only supports packet,
      # event_ip4 and event_ip6.
      # 
      choice :data, :selection => :type_selection do
        packet "packet"
        event_ip4  "ev4"
        event_ip6 "ev6"
      end

      #
      # String padding
      # 
      string :read_length => :padding_length

      #
      # Type Selection
      # 
      # Deterime and call data type based on 
      # the unified2 type attribute
      # 
      def type_selection
        case header.u2type.to_i
        when 1
          # define UNIFIED2_EVENT 1
        when 2
          # define UNIFIED2_PACKET 2
          "packet"
        when 7
          # define UNIFIED2_IDS_EVENT 7
          "ev4"
        when 66
          # define UNIFIED2_EVENT_EXTENDED 66
        when 67
          # define UNIFIED2_PERFORMANCE 67
        when 68
          # define UNIFIED2_PORTSCAN 68
        when 72
          # define UNIFIED2_IDS_EVENT_IPV6 72
          "ev6"
        else
          "unknown type #{header.u2type}"
        end
      end

      #
      # Sometimes the data needs extra padding
      # 
      def padding_length
        if header.u2length > data.num_bytes
          header.u2length - data.num_bytes
        else
          0
        end
      end

    end # class Construct
    
  end # module Construct

end # module Unified2