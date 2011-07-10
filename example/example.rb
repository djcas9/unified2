$:.unshift File.join(File.dirname(__FILE__), "..", "lib")
require 'unified2'
require 'eventmachine'
require 'em-websocket'

# Unified2 Configuration
Unified2.configuration do

  # Sensor Configurations
  sensor :interface => 'en1',
    :name => 'Unified2 Example', :id => 3

  # Load signatures, generate events will be sent over the web socket
  # quickly so we slow down the process of
  # pushing events onto the channel.rs & classifications into memory
  load :signatures, 'seeds/sid-msg.map'

  load :generators, 'seeds/gen-msg.map'

  load :classifications, 'seeds/classification.config'

end

#
# Monitor the unified2 log and process the data.
#
# The second argument is the last event processed by
# the sensor. If the last_event_id column is blank in the
# sensor table it will begin at the first available event.
#
# Unified2.watch('seeds/unified2.log', :first) do |event|
#   next if event.signature.blank?
#
#   puts event
#   puts "\n"
#
# end

class EMUnified

  def initialize(options)
    @channel = options.fetch(:channel)
    @path = options.fetch(:path, 'seeds/unified2.log')
    @position = options.fetch(:position, :first)
  end

  def process
    return nil if @working
    @working ||= true
    
    Unified2.watch(@path, @position) do |event|
      next if event.signature.blank?
      
      @channel.push event
      
      # events will be sent over the web socket
      # quickly so we slow down the process of
      # pushing events onto the channel. 
      sleep 0.1
      
      puts event
      
    end

  end

end

EventMachine.run do

  @channel = EM::Channel.new

  @unified = EMUnified.new({
    :channel => @channel,
    :path => '/var/log/snort/merged.log'
  })

  @process = Proc.new do |event|
      
    @data ||= {
      :event => nil,
      :signatures => [],
      :classifications => [],
      :sources => [],
      :source_ports => [],
      :destinations => [],
      :destination_ports => [],
      :counts => {
        :high => 0,
        :low => 0,
        :medium => 0,
        :tcp => 0,
        :udp => 0,
        :icmp => 0,
        :events => 0 
      }
    }
  
    if event
      
      unless @data[:signatures].include?(event.signature.name)
        @data[:signatures].push event.signature.name
      end
      
      unless @data[:classifications].include?(event.classification.name)
        @data[:classifications].push event.classification.name
      end
      
      unless @data[:sources].include?(event.source_ip)
        @data[:sources].push event.source_ip
      end
      
      unless @data[:destinations].include?(event.destination_ip)
        @data[:destinations].push event.destination_ip
      end
      
      unless @data[:source_ports].include?(event.source_port)
        @data[:source_ports].push event.source_port
      end
      
      unless @data[:destination_ports].include?(event.destination_port)
        @data[:destination_ports].push event.destination_port
      end
      
      case event.severity.to_i
      when 1
        @data[:counts][:high] += 1
      when 2
        @data[:counts][:medium] += 1
      when 3
        @data[:counts][:low] += 1
      end
      
      case event.protocol.to_s.to_sym
      when :TCP
        @data[:counts][:tcp] += 1
      when :UDP
        @data[:counts][:udp] += 1
      when :ICMP
        @data[:counts][:icmp] += 1
      end

      @data[:counts][:events] += 1

      @data[:event] = event
    end
    
    @data.to_json
  end
  
  EventMachine::WebSocket.start(:host => "0.0.0.0", :port => 8080) do |ws|
    
    ws.onopen do    
      @sid = @channel.subscribe do |event|
        ws.send @process.call(event)
      end
      
      ws.send @process.call(false)
      
      EM.defer { @unified.process }
    end

    ws.onclose do
      @channel.unsubscribe(@sid)
    end

  end

end
