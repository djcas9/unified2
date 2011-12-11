require 'packetfu'
require 'ipaddr'
require 'json'

require 'unified2/extra'
require 'unified2/classification'
require 'unified2/packet'
require 'unified2/sensor'
require 'unified2/signature'

#
# Unified2
#
module Unified2

  #
  # Event
  #
  class Event
    
    #
    # Normal Event headers types
    #
    EVENT_TYPES = [7, 72, 104, 105]

    #
    # Extra Data Event Header Types
    #
    EXTRA = [ 110 ]

    #
    # Legacy Event Header Types
    #
    LEGACY_EVENT_TYPES = [7, 72]

    #
    # Packet Event Header Types
    #
    PACKET_TYPES = [2]

    #
    # Setup method defaults
    #
    attr_accessor :id, :event, :packets, :extras, :position,
      :next_position, :file

    #
    # Initialize event
    #
    # @param [Integer] id Event id
    #
    def initialize(id, position)
      @id = id.to_i
      @position = position
      @packets = []
      @extras = []
    end

    #
    # Event length
    #
    # @return [Integer] Event length
    #
    def length
      @event_data[:header][:length].to_i
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
    # Event Header
    #
    def header
      @event_data[:header] || {}
    end

    #
    # Event Time
    #
    # The event timestamp created by unified2.
    #
    # @return [Time, nil] Event time object
    #
    def event_time
      Time.at(@event_data[:timestamp].to_i)
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
      @event_data[:event_microsecond]
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
      @event_data[:packet_action]
    end

    #
    # ICMP?
    # 
    # @return [true, false] Check is protocol is icmp
    # 
    def icmp?
      protocol == :ICMP
    end

    #
    # TCP?
    # 
    # @return [true, false] Check is protocol is tcp
    #
    def tcp?
      protocol == :TCP
    end

    #
    # UDP?
    # 
    # @return [true, false] Check is protocol is udp
    #
    def udp?
      protocol == :UDP
    end

    #
    # Protocol
    #
    # @return [Protocol] Event protocol object
    #
    def protocol
      @protocol ||= determine_protocol
    end

    #
    # Classification
    #
    # @return [Classification] Event classification object
    #
    def classification
      Classification.new(@event_data[:classification])
    end

    #
    # Signature
    #
    # @return [Signature, nil] Event signature object
    #
    def signature
      @signature ||= Signature.new(@event_data[:signature])
    end

    #
    # Source IP Address
    #
    # @return [IPAddr] Event source ip address
    #
    def ip_source
      @event_data[:source_ip]
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
      @event_data[:source_port]
    end

    #
    # Destination IP Address
    #
    # @return [IPAddr] Event destination ip address
    #
    def ip_destination
      @event_data[:destination_ip]
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
      @event_data[:destination_port]
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
    # Packets
    #
    # @yield [Packet] Description
    #
    # @return [Array] Packet object array
    #
    def packets
      return @packets unless block_given?
      @packets.each { |packet| yield packet }
    end

    #
    # Has Packet Data
    #
    # @return [True,False] Does the event have packet data?
    #
    def packets?
      @packets.empty?
    end

    #
    # Extras
    #
    # @yield [Extra] yield event extra objects
    #
    # @return [Array] Extra object array
    #
    def extras
      return @extras unless block_given?
      @extras.each { |extra| yield extra }      
    end

    #
    # Has Extra Data
    #
    # @return [True,False] Does the event have extra data?
    #
    def extras?
      @extras.empty?
    end

    #
    # Load
    # 
    # Initializes the raw data returned by
    # bindata into a more comfortable format.
    # 
    # @param [Hash] Name Description
    # 
    # @return [nil]
    # 
    def load(event)

      if EXTRA.include?(event.header.u2type)
        extra = Extra.new(event)
        @extras.push(extra)
      end

      if EVENT_TYPES.include?(event.header.u2type)
        @event = event
        @event_data = build_event_data
      end

      if PACKET_TYPES.include?(event.header.u2type)
        packet = Packet.new(build_packet_data(event))
        @packets.push(packet)
      end

    end

    #
    # Convert To Hash
    # 
    # @return [Hash] Event hash object
    # 
    def to_h

      @to_hash = {
        :header => header,
        :event_id => id,
        :severity_id => severity,
        :signature => signature.to_h,
        :classification => classification.to_h,
        :sensor => sensor.to_h,
        :checksum => checksum,
        :timestamp => timestamp.to_i,
        :protocol => protocol,
        :next_position => next_position.to_i,
        :position => position,
        :source_ip => @event_data[:source_ip],
        :event_microsecond => @event_data[:event_microsecond],
        :impact_flag => @event_data[:impact_flag],
        :impact => @event_data[:impact],
        :blocked => @event_data[:blocked],
        :mpls_label => @event_data[:mpls_label],
        :vlan_id => @event_data[:vlan_id],
        :destination_port => @event_data[:destination_port],
        :source_port => @event_data[:source_port],
        :policy_id => @event_data[:policy_id],
        :destination_ip => @event_data[:destination_ip],
        :severity => @event_data[:priority_id],
        :packets => [],
        :extras => []
      }

      if file && file.respond_to?(:timestamp)
        @to_hash[:file_timestamp] = file.timestamp.to_i
      end

      extras.each do |extra|
        @to_hash[:extras].push(extra.to_h)
      end

      packets.each do |packet|
        @to_hash[:packets].push(packet.to_h)
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
    # Convert To String
    # 
    # @return [String] Event string object
    # 
    def to_s
      data = "EVENT\n"
      data += "\tevent id: #{id}\n"
      data += "\tsensor id: #{sensor.id}\n"
      data += "\ttimestamp: #{timestamp.strftime('%D %H:%M:%S')}\n"
      data += "\tseverity: #{severity}\n"
      data += "\tprotocol: #{protocol}\n"
      data += "\tsource ip: #{source_ip} (#{source_port})\n"
      data += "\tdestination ip: #{destination_ip} (#{destination_port})\n"
      data += "\tsignature: #{signature.name}\n"
      data += "\tclassification: #{classification.name}\n"
      data += "\tchecksum: #{checksum}\n"

      packet_count = 1
      length = packets.count

      packets.each do |packet|
        data += "\n\tPACKET  (#{packet_count} of #{length})\n\n"

        data += "\tsensor id: #{sensor.id}"
        data += "\tevent id: #{id}"
        data += "\tevent second: #{packet.event_timestamp.to_i}\n"
        data += "\tpacket second: #{packet.timestamp.to_i}"
        data += "\tpacket microsecond: #{packet.microsecond.to_i}\n"
        data += "\tlinktype: #{packet.link_type}"
        data += "\tpacket length: #{packet.length}\n"
        data += "\tchecksum: #{packet.checksum}\n\n"

        hexdump = packet.hexdump(:width => 16)
        hexdump.each_line { |line| data += "\t" + line }

        packet_count += 1
      end

      extra_count = 1
      length = extras.count

      extras.each do |extra|
        data += "\n\tEXTRA   (#{extra_count} of #{length})\n\n"

        data += "\tname: #{extra.name}"
        data += "\tevent type: #{extra.header[:event_type]}"
        data += "\tevent length: #{extra.header[:event_length]}\n"
        data += "\tsensor id: #{sensor.id}"
        data += "\tevent id: #{id}"
        data += "\tevent second: #{extra.timestamp}\n"
        data += "\ttype: #{extra.type_id}"
        data += "\tdata type: #{extra.data_type}"
        data += "\tlength: #{extra.length}\n"
        data += "\tvalue: " + extra.value + "\n"

        extra_count += 1
      end

      data += "\n"
    end

    private

      def build_event_data
        event_hash = {}

        event_hash = {
          :header => {
            :type => @event.header.u2type,
            :length => @event.header.u2length
          },
          :destination_ip => @event.data.ip_destination,
          :priority_id => @event.data.priority_id,
          :signature_revision => @event.data.signature_revision,
          :event_id => @event.data.event_id,
          :protocol => @event.data.protocol,
          :source_port => @event.data.sport_itype,
          :timestamp => @event.data.event_second,
          :destination_port => @event.data.dport_icode,
          :sensor_id => @event.data.sensor_id,
          :generator_id => @event.data.generator_id,
          :source_ip => @event.data.ip_source,
          :event_microsecond => @event.data.event_microsecond
        }

        if LEGACY_EVENT_TYPES.include?(@event.header.u2type)
          event_hash[:packet_action] = @event.data.packet_action
        else
          event_hash.merge!({
            :impact_flag => @event.data.impact_flag,
            :impact => @event.data.impact,
            :blocked => @event.data.blocked,
            :mpls_label => @event.data.mpls_label,
            :vlan_id => @event.data.vlanId,
            :policy_id => @event.data.pad2
          })
        end

        event_hash[:classification] = build_classifications

        if @event.data.generator_id.to_i == 1
          event_hash[:signature] = build_signature
        else
          event_hash[:signature] = build_generator
        end

        event_hash
      end

      def build_packet_data(packet)
        packet_hash = {}
        packet_hash = {
          :linktype => packet.data.linktype,
          :packet_microsecond => packet.data.packet_microsecond,
          :packet_timestamp => packet.data.packet_second,
          :packet => packet.data.packet_data,
          :timestamp => packet.data.event_second,
          :packet_length => packet.data.packet_length
        }

        packet_hash
      end

      def build_generator
        signature = {}

        if Unified2.generators
          key = "#{@event.data.generator_id}.#{@event.data.signature_id}"

          if Unified2.generators.data.has_key?(key)
            sig = Unified2.generators.data[key]

            signature = {
              :signature_id => @event.data.signature_id,
              :generator_id => @event.data.generator_id,
              :revision => @event.data.signature_revision,
              :name => sig[:name],
              :blank => false
            }
          end
        end

        if signature.empty?
          signature = {
            :signature_id => @event.data.signature_id,
            :generator_id => @event.data.generator_id,
            :revision => 0,
            :name => "Unknown Signature #{@event.data.signature_id}",
            :blank => true
          }
        end

        signature
      end

      def build_signature
        signature = {}

        if Unified2.signatures
          key = event.data.signature_id.to_s

          if Unified2.signatures.data.has_key?(key)
            sig = Unified2.signatures.data[key]

            signature = {
              :signature_id => @event.data.signature_id,
              :generator_id => @event.data.generator_id,
              :revision => @event.data.signature_revision,
              :name => sig[:name],
              :blank => false
            }
          end
        end

        if signature.empty?
          signature = {
            :signature_id => @event.data.signature_id,
            :generator_id => @event.data.generator_id,
            :revision => 0,
            :name => "Unknown Signature #{@event.data.signature_id}",
            :blank => true
          }
        end

        signature
      end

      def build_classifications
        classification = {}

        if Unified2.classifications
          key = "#{event.data.classification_id}"

          if Unified2.classifications.data.has_key?(key)
            classification = Unified2.classifications.data[key]

            classification = {
              :classification_id => @event.data.classification_id,
              :name => classification[:name],
              :short => classification[:short],
              :severity => classification[:severity_id]
            }
          end
        end

        if classification.empty?
          classification = {
            :classification_id => @event.data.classification_id,
            :name => 'Unknown',
            :short => 'n/a',
            :severity => 0
          }
        end

        classification
      end

      def determine_protocol
        case @event.data.protocol.to_i
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
