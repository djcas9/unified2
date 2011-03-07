$:.unshift File.dirname(__FILE__) + "/lib"
require 'unified2'
require 'pp'

# Load Signature Maps into memory
Unified2.configuration do
  load 'sid-msg.map'
  load 'sid-msg.map'
end

# Watch the unified2 output for new data
# and process.
Unified2.watch('unified2-example') do |event|
  pp event.event_id
end