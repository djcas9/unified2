#
# Unified2
#
module Unified2

  #
  # Constructor
  #
  module Constructor

    #
    # Unified2 Primitive Namespace
    #
    module Primitive

      #
      # BinData Primitive IP4 Constructor
      #
      class IPV4 < ::BinData::Primitive

        array :octets, :type => :uint8, :initial_length => 4
        
        # IPV4#set
        def set(value)
          ints = value.split(/\./).collect { |int| int.to_i }
          self.octets = ints
        end
        
        # IPV4#get
        def get
          self.octets.collect { |octet| "%d" % octet }.join(".")
        end

      end # class IPV4

    end # class Primitive

  end # module Constructor

end # module Unified2
