require 'bindata'
require 'digest'
require 'socket'

require 'unified2/constructor'
require 'unified2/config_file'
require 'unified2/core_ext'
require 'unified2/event'
require 'unified2/exceptions'
require 'unified2/version'

module Unified2

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

  def self.configuration(options={}, &block)
    @sensor ||= Sensor.new
    self.instance_eval(&block)
  end

  def self.sensor(options={}, &block)
    if block
      @sensor.instance_eval(&block)
    end
    @sensor.update(options)
  end

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
