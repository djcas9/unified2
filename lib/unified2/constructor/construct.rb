require 'unified2/constructor/event_ip4'
require 'unified2/constructor/event_ip6'
require 'unified2/constructor/extra_construct'
require 'unified2/constructor/extra_data'
require 'unified2/constructor/legacy_event_ip4'
require 'unified2/constructor/legacy_event_ip6'
require 'unified2/constructor/record_header'
require 'unified2/constructor/packet'

#
# Unified2
#
module Unified2

  #
  # Unified2 Constructor Namespace
  #
  module Constructor

    #
    # Unified2 Construction
    #
    class Construct < ::BinData::Record

      #
      # Rename record_header to header
      # to simplify and cut down on verbosity
      # 
      record_header :header

      # 
      # Unified2 data types
      # 
      choice :data, :selection => :type_selection do
        packet "packet"
        
        event_ip4  "ev4"
        event_ip6 "ev6"

        legacy_event_ip4  "lev4"
        legacy_event_ip6 "lev6"

        extra_construct "extra_data"
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
      # SNORT DEFINES
      # Long time ago...
      # define UNIFIED2_EVENT               1
      #
      # CURRENT
      # define UNIFIED2_PACKET              2
      # define UNIFIED2_IDS_EVENT           7
      # define UNIFIED2_IDS_EVENT_IPV6      72
      # define UNIFIED2_IDS_EVENT_MPLS      99
      # define UNIFIED2_IDS_EVENT_IPV6_MPLS 100
      # define UNIFIED2_IDS_EVENT_VLAN      104
      # define UNIFIED2_IDS_EVENT_IPV6_VLAN 105
      # define UNIFIED2_EXTRA_DATA          110
      #
      def type_selection
        case header.u2type.to_i
        when 1
          # LEGACY
          # define UNIFIED2_EVENT 1
        when 2
          # define UNIFIED2_PACKET 2
          "packet"
        when 7
          # define UNIFIED2_IDS_EVENT 7
          "lev4"
        when 66
          # LEGACY
          # define UNIFIED2_EVENT_EXTENDED 66
        when 67
          # LEGACY
          # define UNIFIED2_PERFORMANCE 67
        when 68
          # LEGACY
          # define UNIFIED2_PORTSCAN 68
        when 72
          # define UNIFIED2_IDS_EVENT_IPV6 72
          "lev6"
        when 99
          # define UNIFIED2_IDS_EVENT_MPLS 99
          puts "99"
        when 100
          # define UNIFIED2_IDS_EVENT_IPV6_MPLS
          puts "100"
        when 104 
          # define UNIFIED2_IDS_EVENT_VLAN 104
          "ev4"
        when 105
          # define UNIFIED2_IDS_EVENT_IPV6_VLAN 105
          "ev6"
        when 110
          # define UNIFIED2_EXTRA_DATA 110
          "extra_data"
        else
          raise "unknown type #{header.u2type}"
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
