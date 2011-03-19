require 'bindata'
require 'digest'
require 'socket'

require 'unified2/constructor'
require 'unified2/config_file'
require 'unified2/core_ext'
require 'unified2/event'
require 'unified2/exceptions'
require 'unified2/version'

#
# Unified2 Namespace
# 
module Unified2
  
  #
  # Configuration File Types
  # 
  # Holds the available configuration
  # file types current supported.
  # 
  TYPES = [
    :signatures,
    :generators,
    :classifications
  ]
  
  class << self
    attr_accessor :signatures, :generators,
      :sensor, :hostname, :interface,
      :classifications
  end

  #
  # Configuration
  # 
  # @param [Hash] options Sensor Configuration
  # @param [Block] block Configurations
  # 
  # @option options [Integer] :id Sensor id
  # @option options [String] :name Sensor name
  # @option options [String] :interface Sensor interface
  # 
  # @return [nil]
  # 
  def self.configuration(options={}, &block)
    @sensor ||= Sensor.new(options)
    self.instance_eval(&block)
  end
  
  #
  # Sensor
  # 
  # @param [Hash] options Sensor Configuration
  # @param [Block] block Sensor attributes
  # 
  # @option options [Integer] :id Sensor id
  # @option options [String] :hostname Sensor hostname
  # @option options [String] :name Sensor name
  # @option options [String] :interface Sensor interface
  #
  # @return [nil]
  # 
  def self.sensor(options={}, &block)
    if block
      @sensor.instance_eval(&block)
    end
    @sensor.update(options)
  end

  #
  # Load
  # 
  # @param [String] type Configuration type
  # @param [String] path Configuration path
  # 
  # @return [nil]
  # 
  # @raise [FileNotReadable] Path not readable
  # @raise [FileNotFound] File not found
  # 
  def self.load(type, path)
    unless TYPES.include?(type.to_sym)
      raise UnknownLoadType, "Error - #{@type} is unknown."
    end

    if File.exists?(path)
      if File.readable?(path)
        instance_variable_set("@#{type}", ConfigFile.new(type, path))
      else
        raise FileNotReadable, "Error - #{path} not readable."
      end
    else
      raise FileNotFound, "Error - #{path} not found."
    end
  end

  #
  # Watch
  # 
  # Monitor the unified2 file for events and process.
  # 
  # @param [String] path Unified2 file path
  # @param [String,Symbol,Integer] position IO position
  # @param [Block] block Event object
  # 
  # @raise [FileNotReadable] Path not readable
  # @raise [FileNotFound] File not found
  # 
  # @return [nil]
  # 
  def self.watch(path, position=:first, &block)

    unless File.exists?(path)
      raise FileNotFound, "Error - #{path} not found."
    end

    if File.readable?(path)
      io = File.open(path)

      case position
      when Integer, Fixnum

        event_id = position.to_i.zero? ? 1 : position.to_i
        @event = Event.new(event_id)

      when Symbol, String

        case position.to_sym
        when :last

          until io.eof?
            event = Unified2::Constructor::Construct.read(io)
            event_id = event.data.event_id if event
          end

          @event = Event.new(event_id + 1)

          # set event_id to false to catch
          # beginning loop and process
          event_id = false

        when :first

          first_open = File.open(path)
          first_event = Unified2::Constructor::Construct.read(first_open)
          first_open.close
          event_id = first_event.data.event_id
          @event = Event.new(event_id)

        end
      end

      loop do
        begin
          event = Unified2::Constructor::Construct.read(io)

          if event_id
            if event.data.event_id.to_i > (event_id - 1)
              check_event(event, block)
            end
          else
            check_event(event, block)
          end

        rescue EOFError
          sleep 5
          retry
        end
      end

    else
      raise FileNotReadable, "Error - #{path} not readable."
    end
  end
  
  #
  # Read
  # 
  # Read the unified2 log until EOF and process
  # events.
  # 
  # @param [String] path Unified2 file path
  # @param [Block] block Event object
  # 
  # @raise [FileNotReadable] Path not readable
  # @raise [FileNotFound] File not found
  # 
  # @return [nil]
  #
  def self.read(path, &block)

    unless File.exists?(path)
      raise FileNotFound, "Error - #{path} not found."
    end

    if File.readable?(path)
      io = File.open(path)

      first_open = File.open(path)
      first_event = Unified2::Constructor::Construct.read(first_open)
      first_open.close

      @event = Event.new(first_event.data.event_id)

      until io.eof?
        event = Unified2::Constructor::Construct.read(io)
        check_event(event, block)
      end

    else
      raise FileNotReadable, "Error - #{path} not readable."
    end
  end

  private

    def self.check_event(event, block)
      if @event.id == event.data.event_id
        @event.load(event)
      else
        block.call(@event)
        @event = Event.new(event.data.event_id)
        @event.load(event)
      end
    end

end
