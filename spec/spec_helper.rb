gem 'rspec', '~> 2.4'
require 'rspec'

require 'unified2'
include Unified2

module Unified2
  
  def self.first(path)
    unless File.exists?(path)
      raise FileNotFound, "Error - #{path} not found."
    end

    if File.readable?(path)
      io = File.open(path)

      first_open = File.open(path)
      first_event = Unified2::Constructor::Construct.read(first_open)
      first_open.close

      @event = Event.new(first_event.data.event_id)

      loop do
        event = Unified2::Constructor::Construct.read(io)

        if event.data.event_id.to_i == @event.id.to_i
          @event.load(event)
        else
          return @event
        end
      end

    else
      raise FileNotReadable, "Error - #{path} not readable."
    end
  end
  
end

Unified2.configuration do
  sensor :interface => 'en1',
    :name => 'Example Sensor',
    :hostname => 'W0ots.local'

  load :signatures, 'example/seeds/sid-msg.map'
  load :generators, 'example/seeds/gen-msg.map'
  load :classifications, 'example/seeds/classification.config'
end