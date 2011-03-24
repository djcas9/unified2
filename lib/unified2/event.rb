require 'unified2/classification'
require 'unified2/payload'
require 'unified2/protocol'
require 'unified2/sensor'
require 'unified2/signature'

require 'packetfu'
require 'ipaddr'
require 'json'

module Unified2
  #
  # Event
  #
  class Event

    attr_accessor :id, :event_data, :packet_data
    #
    # Initialize event
    #
    # @param [Integer] id Event id
    #
    def initialize(id)
      @id = id.to_i
    end

    #
    # Packet Time
    #
    # Time of creation for the unified2 packet.
    #
    # @return [Time, nil] Packet time object
    #
    def packet_time
      if @packet_data.has_key?(:packet_second)
        @packet_data[:packet_second]
        @timestamp = Time.at(@packet_data[:packet_second].to_i)
      end
    end

    #
    # Checksum
    #
    # Create a unique checksum for each event
    # using the ip source, destination, signature id,
    # generator id, sensor id, severity id, and the
    # classification id.
    #
    # @return [String] Event checksum
    #
    def checksum
      checkdum = [ip_source, ip_destination, signature.id, signature.generator, sensor.id, severity, classification.id]
      Digest::MD5.hexdigest(checkdum.join(''))
    end

    #
    # Event Time
    #
    # The event timestamp created by unified2.
    #
    # @return [Time, nil] Event time object
    #
    def event_time
      if @packet_data.has_key?(:event_second)
        @timestamp = Time.at(@packet_data[:event_second].to_i)
      end
    end
    alias :timestamp :event_time

    #
    # Microseconds
    #
    # The event time in microseconds.
    #
    # @return [String, nil] Event microseconds
    #
    def microseconds
      if @event_data.has_key?(:event_microsecond)
        @microseconds = @event_data[:event_microsecond]
      end
    end

    #
    # Sensor
    #
    # @return [Sensor] Sensor object
    #
    def sensor
      @sensor ||= Unified2.sensor
    end

    #
    # Packet Action
    #
    # @return [Integer, nil] Packet action
    #
    def packet_action
      if @event_data.has_key?(:event_second)
        @packet_data_action = @event_data[:packet_action]
      end
    end

    #
    # Protocol
    #
    # @return [Protocol] Event protocol object
    #
    def protocol
      @protocol = Protocol.new(determine_protocol(@event_data[:protocol]), packet)
    end


    #
    # Classification
    #
    # @return [Classification] Event classification object
    #
    def classification
      @classification = Classification.new(@event_data[:classification]) if @event_data[:classification]
    end

    #
    # Signature
    #
    # @return [Signature, nil] Event signature object
    #
    def signature
      if @event_data.is_a?(Hash)
        @signature = Signature.new(@event_data[:signature])
      end
    end

    #
    # Source IP Address
    #
    # @return [IPAddr] Event source ip address
    #
    def ip_source
      if @event_data.is_a?(Hash)
        @event_data[:ip_source] if @event_data.has_key?(:ip_source)
      end
    end
    alias :source_ip :ip_source

    #
    # Source Port
    #
    # @return [Integer] Event source port
    #
    # @note 
    #   Event#source_port will return zero if the 
    #   event protocol is icmp.
    #
    def source_port
      return 0 if protocol.icmp?
      @source_port = @event_data[:sport_itype] if @event_data.has_key?(:sport_itype)
    end

    #
    # Destination IP Address
    #
    # @return [IPAddr] Event destination ip address
    #
    def ip_destination
      if @event_data.is_a?(Hash)
        @event_data[:ip_destination] if @event_data.has_key?(:ip_destination)
      end
    end
    alias :destination_ip :ip_destination

    #
    # Destination Port
    #
    # @return [Integer] Event destination port
    #
    # @note 
    #   Event#destination_port will return zero if the 
    #   event protocol is icmp.
    #
    def destination_port
      return 0 if protocol.icmp?
      @source_port = @event_data[:dport_icode] if @event_data.has_key?(:dport_icode)
    end

    #
    # Severity
    #
    # @return [Integer] Event severity id
    #
    def severity
      @severity = @event_data[:priority_id].to_i
    end

    #
    # Packet
    # 
    # @return [Packet] Event packet object
    # 
    # @note
    #   Please view the packetfu documentation for more
    #   information. (http://code.google.com/p/packetfu/)
    # 
    def packet
      @packet = PacketFu::Packet.parse(@packet_data[:packet])
    end

    #
    # Payload
    #
    # @return [Payload] Event payload object
    #
    def payload
      Payload.new(packet.payload, @packet_data)
    end
    
    #
    # Load
    # 
    # Initializes the raw data returned by
    # bindata into a more comfurtable format.
    # 
    # @param [Hash] Name Description
    # 
    # @return [nil]
    # 
    def load(event)
      if event.data.respond_to?(:signature_id)
        @event_data ||= build_event_data(event)
      end

      if event.data.respond_to?(:packet_data)
        @packet_data ||= build_packet_data(event)
      end
    end

    #
    # Convert To Hash
    # 
    # @return [Hash] Event hash object
    # 
    def to_h
      @to_hash = {}
      
      [@event_data, @packet_data].each do |hash|
        @to_hash.merge!(hash) if hash.is_a?(Hash)
      end
      
      @to_hash
    end

    #
    # Convert To Integer
    # 
    # @return [Integer] Event id
    # 
    def to_i
      @id.to_i
    end
    
    #
    # Convert To Json
    # 
    # @return [String] Event hash in json format
    # 
    def json
      to_h.to_json
    end

    #
    # IP Header
    # 
    # @return [Hash] IP header
    #
    def ip_header
      if ((packet.is_ip?) && packet.has_data?)
        @ip_header = {
          :ip_ver => packet.ip_header.ip_v,
          :ip_hlen => packet.ip_header.ip_hl,
          :ip_tos => packet.ip_header.ip_tos,
          :ip_len => packet.ip_header.ip_len,
          :ip_id => packet.ip_header.ip_id,
          :ip_frag => packet.ip_header.ip_frag,
          :ip_ttl => packet.ip_header.ip_ttl,
          :ip_proto => packet.ip_header.ip_proto,
          :ip_csum => packet.ip_header.ip_sum
        }
      else
        @ip_header = {}
      end
    end
    
    #
    # Convert To String
    # 
    # @return [String] Event string object
    # 
    def to_s
      data = %{
        Sensor: #{sensor.id}
        Event ID: #{id}
        Timestamp: #{timestamp.strftime('%D %H:%M:%S')}
        Severity: #{severity}
        Protocol: #{protocol}
        Source IP: #{source_ip}:#{source_port}
        Destination IP: #{destination_ip}:#{destination_port}
        Signature: #{signature.name}
        Classification: #{classification.name}
        Event Checksum: #{checksum}
      }
      unless payload.blank?
        data += "Payload Checksum: #{payload.checksum}\n"
        data += "Payload:\n"
        payload.dump(:width => 30, :output => data)
      end

      data.gsub(/^\s+/, "")
    end

    private

      def build_event_data(event)
        @event_hash = {}

        @event_hash = {
          :ip_destination => event.data.ip_destination,
          :priority_id => event.data.priority_id,
          :signature_revision => event.data.signature_revision,
          :event_id => event.data.event_id,
          :protocol => event.data.protocol,
          :sport_itype => event.data.sport_itype,
          :event_second => event.data.event_second,
          :packet_action => event.data.packet_action,
          :dport_icode => event.data.dport_icode,
          :sensor_id => event.data.sensor_id,
          :generator_id => event.data.generator_id,
          :ip_source => event.data.ip_source,
          :event_microsecond => event.data.event_microsecond
        }

        build_classifications(event)

        if event.data.generator_id.to_i == 1
          build_signature(event)
        else
          build_generator(event)
        end

        @event_hash
      end

      def build_packet_data(event)
        @packet_hash = {}
        @packet_hash = {
          :linktype => event.data.linktype,
          :packet_microsecond => event.data.packet_microsecond,
          :packet_second => event.data.packet_second,
          :packet => event.data.packet_data,
          :event_second => event.data.event_second,
          :packet_length => event.data.packet_length
        }

        @packet_hash
      end

      def build_generator(event)
        if Unified2.generators.data
          if Unified2.generators.data.has_key?("#{event.data.generator_id}.#{event.data.signature_id}")
            sig = Unified2.generators.data["#{event.data.generator_id}.#{event.data.signature_id}"]

            @event_hash[:signature] = {
              :signature_id => event.data.signature_id,
              :generator_id => event.data.generator_id,
              :revision => event.data.signature_revision,
              :name => sig[:name],
              :blank => false
            }
          end
        end

        unless @event_hash.has_key?(:signature)
          @event_hash[:signature] = {
            :signature_id => event.data.signature_id,
            :generator_id => event.data.generator_id,
            :revision => 0,
            :name => "Unknown Signature #{event.data.signature_id}",
            :blank => true
          }
        end
      end

      def build_signature(event)
        if Unified2.signatures.data
          if Unified2.signatures.data.has_key?(event.data.signature_id.to_s)
            sig = Unified2.signatures.data[event.data.signature_id.to_s]

            @event_hash[:signature] = {
              :signature_id => event.data.signature_id,
              :generator_id => event.data.generator_id,
              :revision => event.data.signature_revision,
              :name => sig[:name],
              :blank => false
            }
          end
        end

        unless @event_hash.has_key?(:signature)
          @event_hash[:signature] = {
            :signature_id => event.data.signature_id,
            :generator_id => event.data.generator_id,
            :revision => 0,
            :name => "Unknown Signature #{event.data.signature_id}",
            :blank => true
          }
        end
      end

      def build_classifications(event)
        if Unified2.classifications.data
          if Unified2.classifications.data.has_key?("#{event.data.classification_id}")
            classification = Unified2.classifications.data["#{event.data.classification_id}"]

            @event_hash[:classification] = {
              :classification_id => event.data.classification_id,
              :name => classification[:name],
              :short => classification[:short],
              :severity => classification[:severity_id]
            }
          end
        end

        unless @event_hash.has_key?(:classification)
          @event_hash[:classification] = {
            :classification_id => event.data.classification_id,
            :name => 'Unknown',
            :short => 'n/a',
            :severity => 0
          }
        end
      end

      def determine_protocol(protocol)
        case protocol.to_i
        when 1
          :ICMP # ICMP (Internet Control Message Protocol) packet type.
        when 2
          :IGMP # IGMP (Internet Group Message Protocol) packet type.
        when 6
          :TCP # TCP (Transmition Control Protocol) packet type.
        when 17
          :UDP # UDP (User Datagram Protocol) packet type.
        else
          :'N/A'
        end
      end

  end # class Event

end # module Unified2
