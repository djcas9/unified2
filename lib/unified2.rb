require 'bindata'
require 'socket'
# http://cvs.snort.org/viewcvs.cgi/snort/src/output-plugins/spo_unified2.c?rev=1.3&content-type=text/vnd.viewcvs-markup

require 'unified2/construct'
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
      raise UnknownLoadType, "Error - #{type} is unknown."
    end

    if File.exists?(path)
      instance_variable_set("@#{type}", {})
    else
      raise FileNotFound, "Error - #{path} not found."
    end

    if File.readable?(path)
      file = File.open(path)

      case type.to_sym
      when :classifications
        
        count = 0
        file.each_line do |line|
          next if line[/^\#/]
          next unless line[/^config\s/]
          count += 1
          
          # attempted-dos,Attempted Denial of Service,2
          data = line.gsub!(/config classification: /, '')
          short, name, priority = data.to_s.split(',')
          
          @classifications[count.to_s] = {
            :short => short,
            :name => name,
            :priority => priority.to_i
          }
        end
        
      when :generators

        file.each_line do |line|
          next if line[/^\#/]
          generator_id, alert_id, name = line.split(' || ')
          id = "#{generator_id}.#{alert_id}"

          @generators[id] = {
            :generator_id => generator_id,
            :name => name,
            :alert_id => alert_id
          }
        end

      when :signatures

        file.each_line do |line|
          next if line[/^\#/]
          id, body, *references = line.split(' || ')
          @signatures[id] = {
            :id => id,
            :name => body,
            :references => references
          }
        end

      end

    end
  end

  def self.watch(path, position=:last, &block)

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
            event = Unified2::Construct.read(io)
            event_id = event.data.event_id if event
          end
          
          @event = Event.new(event_id + 1)
          
          # set event_id to false to catch
          # beginning loop and process
          event_id = false

        when :first

          first_open = File.open(path)
          first_event = Unified2::Construct.read(first_open)
          first_open.close
          event_id = first_event.data.event_id
          @event = Event.new(event_id)

        end
      end

      loop do
        begin
          event = Unified2::Construct.read(io)

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
      first_event = Unified2::Construct.read(first_open)
      first_open.close

      @event = Event.new(first_event.data.event_id)

      until io.eof?
        event = Unified2::Construct.read(io)
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
