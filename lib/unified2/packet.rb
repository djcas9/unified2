require 'hexdump'
require 'unified2/payload'
require 'unified2/protocol'

module Unified2
  #
  # Packet
  # 
  class Packet

    attr_reader :link_type, :event_id,
      :microsecond, :timestamp, :length,
      :raw, :event_timestamp

    def initialize(packet)
      @raw = packet
      @link_type = packet[:linktype]
      @microsecond = packet[:packet_microsecond]

      @event_timestamp = Time.at(packet[:timestamp])
      @timestamp = Time.at(packet[:packet_timestamp])
      @length = packet[:packet_length].to_i
      @event_id = packet[:event_id]

      @packet ||= PacketFu::Packet.parse(packet[:packet])
      @protocol = @packet.protocol.last.to_sym
    end

    #
    # IP Header
    # 
    # @return [Hash] IP header
    #
    def ip_header
      if @packet.is_ip?
        @ip_header = {
          :ip_ver => @packet.ip_header.ip_v,
          :ip_hlen => @packet.ip_header.ip_hl,
          :ip_tos => @packet.ip_header.ip_tos,
          :ip_len => @packet.ip_header.ip_len,
          :ip_id => @packet.ip_header.ip_id,
          :ip_frag => @packet.ip_header.ip_frag,
          :ip_ttl => @packet.ip_header.ip_ttl,
          :ip_proto => @packet.ip_header.ip_proto,
          :ip_csum => @packet.ip_header.ip_sum
        }
      else
        @ip_header = {}
      end

      @ip_header
    end

    def protocol
      @proto ||= Protocol.new(@protocol, @packet)
    end

    #
    # String
    #
    # @return [String] Signature name
    #
    def to_s
      payload.to_s
    end

    #
    # Payload
    #
    # @return [Payload] Event payload object
    #
    def payload
      @packet.payload
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
    def hex(include_header=true)
      packet = if include_header
                 @packet.to_s
               else
                 @packet.payload.to_s
               end

      hex = packet.unpack('H*')
      return hex.first if hex
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
    # @note
    #   Please view the hexdump documentation for more
    #   information. Hexdump is a great lib by @postmodern. 
    #   (http://github.com/postmodern/hexdump)
    # 
    def dump(options={})
      packet = if options[:header]
                 @raw[:packet]
               else
                 @packet.payload
               end

      Hexdump.dump(packet, options)
    end

    def hexdump(options={})
      hexdump = options[:output] ||= ""
      options[:width] ||= 30
      options[:header] ||= true

      dump(options)
      hexdump
    end
    
    #
    # Checksum
    #
    # Create a unique payload checksum
    #
    # @return [String] Payload checksum
    #
    def checksum
      Digest::MD5.hexdigest(hex(false))
    end

  end # class Packet

end # module Unified2
