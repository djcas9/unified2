require 'unified2/signature'
require 'ipaddr'

module Unified2

  class Event

    attr_accessor :id, :metadata, :packet

    def initialize(id)
      @id = id
    end

    def signature
      @signature = Signature.new(@metadata[:signature])
    end

    def ip_destination
      @metadata[:ip_destination] if @metadata.has_key?(:ip_destination)
    end

    def ip_source
      @metadata[:ip_source] if @metadata.has_key?(:ip_source)
    end

    def load(event)
      if event.data.respond_to?(:signature_id)
        @metadata ||= build_event_metadata(event)
      end

      if event.data.respond_to?(:packet_data)
        @packet ||= build_packet_metadata(event)
      end
    end

    private

      def build_event_metadata(event)
        hash ||= {}

        hash = {
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
          :classification_id => event.data.classification_id,
          :generator_id => event.data.generator_id,
          :ip_source => event.data.ip_source,
          :event_microsecond => event.data.event_microsecond
        }

        if Unified2.signatures
          if Unified2.signatures.has_key?(event.data.signature_id.to_s)
            sig = Unified2.signatures[event.data.signature_id.to_s]

            hash[:signature] = {
              :signature_id => event.data.signature_id,
              :name => sig[:name],
              :references => sig[:references]
            }

          end
        else
          hash[:signature] = {
            :signature_id => event.data.signature_id,
            :name => "Unknow Signature #{event.data.signature_id}",
            :references => []
          }
        end

        hash
      end

      def build_packet_metadata(event)
        hash ||= {}
        hash = {
          :linktype => event.data.linktype,
          :packet_microsecond => event.data.packet_microsecond,
          :packet_second => event.data.packet_second,
          :data => event.data.packet_data.to_s.unpack('H*'),
          :event_second => event.data.event_second,
          :packet_length => event.data.packet_length
        }

        hash
      end

  end
end
