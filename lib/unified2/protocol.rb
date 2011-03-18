module Unified2
  class Protocol

    def initialize(protocol, packet=nil)
      @protocol = protocol
      @packet = packet
    end

    def header
      if @packet.has_data?
        if @packet.send(:"is_#{@protocol.downcase}?")
          @packet.send(:"#{@protocol.downcase}_header")
        end
      else
        nil
      end
    end

    def icmp?
      return true if @protocol == :ICMP
      false
    end

    def tcp?
      return true if @protocol == :TCP
      false
    end

    def udp?
      return true if @protocol == :UDP
      false
    end

    def to_s
      @protocol.to_s
    end

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
          :sum => header.udp_sum,
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
          :sum => header.tcp_sum,
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
