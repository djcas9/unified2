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
    # Protocol Header
    # 
    # @return [Object, nil] Protocol header object
    # 
    def header
      if @packet.has_data?
        if @packet.send(:"is_#{@protocol.downcase}?")
          @packet.send(:"#{@protocol.downcase}_header")
        end
      else
        nil
      end
    end

    #
    # ICMP?
    # 
    # @return [true, false] Check is protocol is icmp
    # 
    def icmp?
      return true if @protocol == :ICMP
      false
    end

    #
    # TCP?
    # 
    # @return [true, false] Check is protocol is tcp
    #
    def tcp?
      return true if @protocol == :TCP
      false
    end

    #
    # UDP?
    # 
    # @return [true, false] Check is protocol is udp
    #
    def udp?
      return true if @protocol == :UDP
      false
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
      if send(:"#{@protocol.downcase}?")
        self.send(:"#{@protocol.downcase}")
      else
        {}
      end
    end

    private
      
      def icmp(include_body=false)
        @icmp = {
          :length => header.len,
          :type => header.icmp_type,
          :csum => header.icmp_sum,
          :code => header.icmp_code
        }
        
        @icmp[:body] = header.body if include_body
        
        @icmp
      end

      def udp(include_body=false)
        @udp = {
          :length => header.len,
          :csum => header.udp_sum,
        }
        
        @udp[:body] = header.body if include_body
        
        @udp
      end

      def tcp(include_body=false)
        @tcp = {
          :length => header.len,
          :seq => header.tcp_seq,
          :ack => header.tcp_ack,
          :win => header.tcp_win,
          :csum => header.tcp_sum,
          :urg => header.tcp_urg,
          :hlen => header.tcp_hlen,
          :reserved => header.tcp_reserved,
          :ecn => header.tcp_ecn,
          :opts => header.tcp_opts,
          :opts_len => header.tcp_opts_len,
          :rand_port => header.rand_port,
          :options => header.tcp_options
        }
        
        @tcp[:body] = header.body if include_body
        
        @tcp
      end

  end
end
