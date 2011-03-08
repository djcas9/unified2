#
# rUnified2 - A ruby interface for unified2 output.
#
# Copyright (c) 2010 Dustin Willis Webber (dustin.webber at gmail.com)
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
#

require 'ipaddr'
require 'json'
require 'unified2/sensor'
require 'unified2/signature'

module Unified2

  class Event

    attr_accessor :id, :metadata, :packet

    def initialize(id)
      @id = id
    end

    def sensor
      @sensor ||= Unified2.sensor
    end
    
    def protocol
      @metadata[:protocol] if @metadata.has_key?(:protocol)
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

    def source_port
      @metadata[:sport_itype] if @metadata.has_key?(:sport_itype)
    end

    def ip_destination
      if @metadata.is_a?(Hash)
        @metadata[:ip_destination] if @metadata.has_key?(:ip_destination)
      end
    end
    
    def destination_port
      @metadata[:dport_icode] if @metadata.has_key?(:dport_icode)
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
          :classification_id => event.data.classification_id,
          :generator_id => event.data.generator_id,
          :ip_source => event.data.ip_source,
          :event_microsecond => event.data.event_microsecond
        }
        
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
          :data => event.data.packet_data.to_s.unpack('H*'),
          :event_second => event.data.event_second,
          :packet_length => event.data.packet_length
        }

        @packet_hash
      end

      def build_generator(event)
        if Unified2.generators
          if Unified2.generators.has_key?("#{event.data.generator_id}.#{event.data.signature_id}")
            sig = Unified2.generators["#{event.data.generator_id}.#{event.data.signature_id}"]

            @event_hash[:signature] = {
              :signature_id => event.data.signature_id,
              :name => sig[:name],
              :references => sig[:references]
            }
          end
        end

        unless @event_hash.has_key?(:signature)
          @event_hash[:signature] = {
            :signature_id => event.data.signature_id,
            :name => "",
            :references => []
          }
        end
      end

      def build_signature(event)
        if Unified2.signatures
          if Unified2.signatures.has_key?(event.data.signature_id.to_s)
            sig = Unified2.signatures[event.data.signature_id.to_s]

            @event_hash[:signature] = {
              :signature_id => event.data.signature_id,
              :name => sig[:name],
              :references => sig[:references]
            }
          end
        end

        unless @event_hash.has_key?(:signature)
          @event_hash[:signature] = {
            :signature_id => event.data.signature_id,
            :name => "",
            :references => []
          }
        end
      end

  end
end
