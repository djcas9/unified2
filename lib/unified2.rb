require 'bindata'
# http://cvs.snort.org/viewcvs.cgi/snort/src/output-plugins/spo_unified2.c?rev=1.3&content-type=text/vnd.viewcvs-markup
 
require 'unified2/construct'
require 'unified2/event'
require 'unified2/plugin'
require 'unified2/version'

module Unified2

  class << self
    attr_accessor :signatures, :plugin
  end

  def self.configuration(&block)
    self.instance_eval(&block)
  end

  def self.plugin(plugin, options)
    adaptor = Plugin.new(plugin, options)
  end

  def self.load(path)
    @signatures ||= {}

    unless File.exists?(path)
      raise('Error - file does not exist!')
    end

    if File.readable?(path)
      file = File.open(path)

      file.each_line do |line|
        id, body, *references = line.split(' || ')
        @signatures[id] = {
          :id => id,
          :name => body,
          :references => references
        }
      end
    end
  end

  def self.watch(path, options={}, &block)
    event_id = options[:start] || false
    timeout = options[:timeout].to_i || 5

    unless File.exists?(path)
      raise('Error - file does not exist.')
    end

    if File.readable?(path)
      io = File.open(path)

      if event_id
        @event = Event.new(event_id.to_i)
      else
        first_open = File.open(path)
        first_event = Unified2::Construct.read(first_open)
        first_open.close
        @event = Event.new(first_event.data.event_id)
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
          sleep timeout
          retry
        end
      end

    else
      raise('Error - File not readable.')
    end
  end

  def self.read(path, options={}, &block)
    limit = options[:limit] ? (options[:limit] * 2) : 10 # 5 records
    count = 0

    unless File.exists?(path)
      raise('Error - file does not exist.')
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

        count += 1
        exit if count > limit
      end

    else
      raise('Error - File not readable.')
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
