require 'gibbler'
require 'ipaddr'
require 'json'
require 'unified2/classification'
require 'unified2/payload'
require 'unified2/sensor'
require 'unified2/signature'

module Unified2
  
  class Event
    include Gibbler::Complex
    
    attr_accessor :id, :metadata, :packet

    def initialize(id)
      @id = id
    end

    def packet_time
      if @packet.has_key?(:packet_second)
        @packet[:packet_second]
        @timestamp = Time.at(@packet[:packet_second].to_i)
      end
    end

    def checksum
      #self.gibbler
    end

    def uid
      "#{sensor.id}.#{@id}"
    end

    def event_time
      if @packet.has_key?(:event_second)
        @timestamp = Time.at(@packet[:event_second].to_i)
      end
    end
    alias :timestamp :event_time

    def microseconds
      if @metadata.has_key?(:event_microsecond)
        @microseconds = @metadata[:event_microsecond]
      end
    end

    def sensor
      @sensor ||= Unified2.sensor
    end

    def packet_action
      if @metadata.has_key?(:event_second)
        @packet_action = @metadata[:packet_action]
      end
    end

    def protocol
      if @metadata.has_key?(:protocol)
        @protocol = determine_protocol(@metadata[:protocol])
      end
    end

    def icmp?
      return true if protocol == :ICMP
      false
    end

    def tcp?
      return true if protocol == :TCP
      false
    end

    def udp?
      return true if protocol == :UDP
      false
    end

    def classification
      if @metadata.is_a?(Hash)
        @classification = Classification.new(@metadata[:classification]) if @metadata[:classification]
      end
    end

    def signature
      if @metadata.is_a?(Hash)
        @signature = Signature.new(@metadata[:signature])
      end
    end

    def generator_id
      if @metadata.is_a?(Hash)
        @metadata[:generator_id] if @metadata.has_key?(:generator_id)
      end
    end

    def ip_source
      if @metadata.is_a?(Hash)
        @metadata[:ip_source] if @metadata.has_key?(:ip_source)
      end
    end
    alias :source_ip :ip_source

    # Add ICMP type
    def source_port
      return 0 if icmp?
      @source_port = @metadata[:sport_itype] if @metadata.has_key?(:sport_itype)
    end

    def ip_destination
      if @metadata.is_a?(Hash)
        @metadata[:ip_destination] if @metadata.has_key?(:ip_destination)
      end
    end
    alias :destination_ip :ip_destination

    # Add ICMP code
    def destination_port
      return 0 if icmp?
      @source_port = @metadata[:dport_icode] if @metadata.has_key?(:dport_icode)
    end

    def severity
      @severity = @metadata[:priority_id] if @metadata.has_key?(:priority_id)
    end

    def payload
      if @packet.is_a?(Hash)
        Payload.new(@packet)
      else
        Payload.new
      end
    end

    def load(event)
      if event.data.respond_to?(:signature_id)
        @metadata ||= build_event_metadata(event)
      end

      if event.data.respond_to?(:packet_data)
        @packet ||= build_packet_metadata(event)
      end
    end

    def to_h
      if @metadata.is_a?(Hash)
        if @packet.is_a?(Hash)
          data = {}
          data.merge!(@metadata)
          data.merge!(@packet)
          return data
        end
      else
        if @packet.is_a?(Hash)
          return @packet
        end
      end
    end

    def to_i
      @id.to_i
    end

    def json
      to_h.to_json
    end

    def to_s
data = %{
#############################################################################
# Sensor: #{sensor.id}
# Event ID: #{id}
# Timestamp: #{timestamp}
# Severity: #{severity}
# Protocol: #{protocol}
# Source IP: #{source_ip}:#{source_port}
# Destination IP: #{destination_ip}:#{destination_port}
# Signature: #{signature.name}
# Classification: #{classification.name}
# Payload:

}
      if payload.blank?
        data + '#############################################################################'
      else
        payload.dump(:width => 30, :output => data)
        data + "#############################################################################"
      end
    end

    private

      def build_event_metadata(event)
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

      def build_packet_metadata(event)
        @packet_hash = {}
        @packet_hash = {
          :linktype => event.data.linktype,
          :packet_microsecond => event.data.packet_microsecond,
          :packet_second => event.data.packet_second,
          :payload => event.data.packet_data,
          :event_second => event.data.event_second,
          :packet_length => event.data.packet_length
        }

        @packet_hash
      end

      def build_generator(event)
        if Unified2.generators.data
          if Unified2.generators.data.has_key?("#{event.data.generator_id}.#{event.data.signature_id}")
            sig = Unified2.generators["#{event.data.generator_id}.#{event.data.signature_id}"]

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

  end
end
