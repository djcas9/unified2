gem 'rspec', '~> 2.4'
require 'rspec'

require 'unified2'
include Unified2

module Unified2
  
  def self.first(path)
    validate_path(path)

    io = File.open(path)
    io.sysseek(0, IO::SEEK_SET)

    @event = Event.new(1)

    loop do
      event = Unified2::Constructor::Construct.read(io)
      if event.data.respond_to?(:event_id)
        return @event if event.data.event_id != @event.id
      end

      @event.load(event)
    end
  end
  
end

Unified2.configuration do
  sensor :interface => 'en1',
    :name => 'Example Sensor',
    :hostname => 'W0ots.local',
    :id => 50000000000

  load :signatures, 'example/seeds/sid-msg.map'
  load :generators, 'example/seeds/gen-msg.map'
  load :classifications, 'example/seeds/classification.config'
end
