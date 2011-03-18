require 'hexdump'

module Unified2
  class Payload

    attr_accessor :linktype, :length, :packet

    #
    # Initialize payload object
    #
    # @param [String] raw Raw binary payload
    # @param [Hash] packet Packet attributes
    #
    # @option packet [String] :packet Packet
    # @option packet [Integer] :packet_length Packet length
    # @option packet [Integer] :linktype Packet linktype
    #
    def initialize(raw, packet={})
      @packet = raw
      @length = packet[:packet_length].to_i
      @linktype = packet[:linktype]
    end

    #
    # Blank?
    #
    # @return [true, false] Check is payload is blank
    #
    def blank?
      return true unless @packet
      false
    end

    #
    # Raw
    #
    # @return [String] Raw binary payload
    #
    def raw
      @packet
    end

    #
    # Hex
    #
    # @return [String] Convert payload to hex
    #
    def hex
      @hex = @packet.to_s.unpack('H*')
      return @hex.first if @hex
      nil
    end

    #
    # Dump
    #
    # @param [options] options Hash of options for Hexdump#dump
    #
    # @option options [Integer] :width (16)
    #   The number of bytes to dump for each line.
    #
    # @option options [Symbol, Integer] :base (:hexadecimal)
    #   The base to print bytes in. Supported bases include, `:hexadecimal`,
    #   `:hex`, `16, `:decimal`, `:dec`, `10, `:octal`, `:oct`, `8`,
    #   `:binary`, `:bin` and `2`.
    #
    # @option options [Boolean] :ascii (false)
    #   Print ascii characters when possible.
    #
    # @option options [#<<] :output (STDOUT)
    #   The output to print the hexdump to.
    #
    # @yield [index,hex_segment,print_segment]
    #   The given block will be passed the hexdump break-down of each segment.
    #
    # @yieldparam [Integer] index
    #   The index of the hexdumped segment.
    #
    # @yieldparam [Array<String>] hex_segment
    #   The hexadecimal-byte representation of the segment.
    #
    # @yieldparam [Array<String>] print_segment
    #   The print-character representation of the segment.
    #
    # @return [nil]
    #
    # @raise [ArgumentError]
    #   The given data does not define the `#each_byte` method, or
    #
    # 
    # @note
    #   Please view the hexdump documentation for more
    #   information. Hexdump is a great lib by @postmodern. 
    #   (http://github.com/postmodern/hexdump)
    # 
    def dump(options={})
      Hexdump.dump(@packet, options)
    end

  end
end
