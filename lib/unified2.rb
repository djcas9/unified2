require 'bindata'
require 'digest'
require 'socket'

require 'unified2/constructor'
require 'unified2/config_file'
require 'unified2/core_ext'
require 'unified2/event'
require 'unified2/exceptions'
require "unified2/paths"
require 'unified2/version'

#
# Unified2
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
  # @yield [ConfigFile] block Configurations
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
  # @yield [Sensor] block Sensor attributes
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
  # @yield [Event] block Event object
  # 
  # @raise [FileNotReadable] Path not readable
  # @raise [FileNotFound] File not found
  # @raise [BinaryReadError] Invalid position or file
  # 
  # @return [nil]
  # 
  def self.watch(path, position=:first, &block)
    validate_path(path)

    io = File.open(path)

    case position      
    when Integer
      io.sysseek(position, IO::SEEK_CUR)

    when Symbol, String
    
      if position == :last
        io.sysseek(0, IO::SEEK_END)
      else
        io.sysseek(0, IO::SEEK_SET)
      end
   
    else
      io.sysseek(0, IO::SEEK_SET)
    end

    # Start with a null event.
    # This will always be ignored.
    @event = Event.new(0, 0)

    loop do
      begin
        position = io.pos
        event = Unified2::Constructor::Construct.read(io)
        check_event(event, position, block)
      rescue EOFError
        sleep 5
        retry
      end
    end

  rescue RuntimeError
    raise(BinaryReadError, "incorrect file format or position seek error")
  rescue Interrupt
    io.pos if io
  ensure
    io.close if io
  end
  
  #
  # Read
  # 
  # Read the unified2 log until EOF and process
  # events.
  # 
  # @param [String] path Unified2 file path
  # @yield [Event] block Event object
  # 
  # @raise [FileNotReadable] Path not readable
  # @raise [FileNotFound] File not found
  # 
  # @return [nil]
  #
  def self.read(path, &block)
    validate_path(path)

    io = File.open(path)
    
    # Start with a null event.
    # This will always be ignored.
    @event = Event.new(0, 0)

    until io.eof?
      position = io.pos
      event = Unified2::Constructor::Construct.read(io)
      check_event(event, position, block)
    end

  rescue Interrupt
  ensure
    io.close if io
  end

  def self.glob(path, options={}, &block)
    event_id = options.fetch(:event_id, 0)
    timestamp = options.fetch(:timestamp, nil)
    position = options.fetch(:position, 0)

    paths = Paths.new(Dir.glob(path), timestamp)

    validate_path(path) if paths.all.empty?

    event_id += 1

    paths.read do |path|
      file = path
      p file
      self.read(path.to_s) do |event|
        event.id = event_id
        event.file = path
        block.call(event)
        event_id += 1
      end
    end

    p paths.watch.to_s
    self.watch(paths.watch.to_s, position) do |event|
      event.id = event_id
      event.file = paths.watch
      block.call(event)
      event_id += 1
    end
  end

  private

  def self.validate_path(path)
    unless File.exists?(path)
      raise FileNotFound, "Error - #{path} not found."
    end

    unless File.readable?(path)
      raise FileNotReadable, "Error - #{path} not readable."
    end 
  end

  def self.check_event(event, position=0, block)
    
    if event.data.respond_to?(:event_id)
      if @event.id == event.data.event_id
        @event.load(event)
      else
        @event.next_position = position
        block.call(@event) unless @event.id.zero?
        @event = Event.new(event.data.event_id, position.to_i)
        @event.load(event)
      end
    else 
      @event.load(event)
    end

  end

end
