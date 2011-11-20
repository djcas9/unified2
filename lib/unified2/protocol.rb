#
# Unified2
#
module Unified2
  #
  # Protocol
  #
  class Protocol
    
    #
    # Initialize protocol object
    # 
    # @param [String] protocol Event protocol
    # 
    # @param [Event#packet] packet PacketFu object
    # 
    def initialize(protocol, packet=nil)
      @protocol = protocol
      @packet = packet
    end

    #
    # ICMP?
    # 
    # @return [true, false] Check is protocol is icmp
    # 
    def icmp?
      @protocol == :ICMP
    end

    #
    # TCP?
    # 
    # @return [true, false] Check is protocol is tcp
    #
    def tcp?
      @protocol == :TCP
    end

    #
    # UDP?
    # 
    # @return [true, false] Check is protocol is udp
    #
    def udp?
      @protocol == :UDP
    end

    #
    # Convert To String
    # 
    # @return [String] Protocol
    # 
    # @example 
    #   event.protocol #=> 'TCP'
    # 
    def to_s
      @protocol.to_s
    end

    #
    # Convert To Hash
    # 
    # @return [Hash] Protocol header hash object
    # 
    # @example
    #   event.protocol.to_h #=> {:length=>379, :seq=>3934511163, :ack=>1584708129 ... }
    # 
    def to_h
      hash = {
        :type => @protocol.to_s
      }

      if send(:"#{@protocol.downcase}?")
        hash.merge!(self.send(:"#{@protocol.downcase}"))
      end

      hash
    end
    alias header to_h

    private
      
    def hdr
      return nil unless @packet.send(:"is_#{@protocol.downcase}?")
      @packet.send(:"#{@protocol.downcase}_header")
    end

    def icmp(include_body=false)
      icmp = {
        :length => hdr.len,
        :type => hdr.icmp_type,
        :csum => hdr.icmp_sum,
        :code => hdr.icmp_code
      }
      
      icmp[:body] = hdr.body if include_body
      
      icmp
    end

    def udp(include_body=false)
      udp = {
        :length => hdr.len,
        :csum => hdr.udp_sum,
      }
      
      udp[:body] = hdr.body if include_body
      
      udp
    end

    def tcp(include_body=false)
      tcp = {
        :length => hdr.len,
        :seq => hdr.tcp_seq,
        :ack => hdr.tcp_ack,
        :win => hdr.tcp_win,
        :csum => hdr.tcp_sum,
        :urg => hdr.tcp_urg,
        :hlen => hdr.tcp_hlen,
        :reserved => hdr.tcp_reserved,
        :ecn => hdr.tcp_ecn,
        :opts_len => hdr.tcp_opts_len,
        :rand_port => hdr.rand_port,
        :options => hdr.tcp_options
      }
      
      tcp[:body] = hdr.body if include_body
      
      tcp
    end

  end
end
