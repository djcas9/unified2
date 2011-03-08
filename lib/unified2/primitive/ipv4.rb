module Unified2
  module Primitive
    
    class IPV4 < ::BinData::Primitive
      array :octets, :type => :uint8, :initial_length => 4

      def set(val)
        ints = val.split(/\./).collect { |int| int.to_i }
        self.octets = ints
      end

      def get
        self.octets.collect { |octet| "%d" % octet }.join(".")
      end

    end
    
  end
end