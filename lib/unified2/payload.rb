require 'hexdump'

module Unified2
  class Payload
    
    attr_accessor :linktype, :length
    
    def initialize(payload={})
      @payload = payload[:payload]
      @length = payload[:packet_length].to_i
      @linktype = payload[:linktype]
    end

    def blank?
      return true unless @payload
      false
    end

    def raw
      @payload.to_s
    end
    
    def hex
      @hex = @payload.to_s.unpack('H*')
      return @hex.first if @hex
      nil
    end

    def dump(options={})
      Hexdump.dump(@payload, options)
    end

  end
end