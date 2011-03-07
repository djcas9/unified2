require 'rubygems'
require 'pp'

file = File.open('sid-msg.map')

rules = {}
count = 0

file.each_line do |line|
  id, body, *references = line.split(' || ')
  rules[id] = {
    :id => id,
    :name => body,
    :references => references
  }
end

pp rules['485']
