# unified2

* [Homepage](http://github.com/mephux/unified2)
* [Issues](http://github.com/mephux/unified2/issues)
* [Documentation](http://rubydoc.info/gems/unified2/frames)
* [Email](mailto:dustin.webber at gmail.com)

## Description

A ruby interface for unified2 output. rUnified2 allows you to manipulate unified2 output for custom storage and/or analysis.

## Features

 * Monitor/Read unified2 logs & manipulate the data.
 * Numerous connivence methods
 * Simple & Intuitive to Use

## Examples

``` ruby
require 'unified2'

#
# Load rules into memory
#

Unified2.configuration do
 # Sensor Configurations
 sensor :id => 1, :name => 'Test Sensor', :interface => 'en1'

 # Load signatures, generators & classifications into memory
 load :signatures, 'sid-msg.map'
 load :generators, 'gen-msg.map'
 load :classifications, 'classification.config'
end

#
# Unified2#watch
#
# Watch a unified2 file for changes and process the results.
# 

Unified2.watch('/var/log/snort/merged.log', :last) do |event|
 next if event.signature.name.blank?
 puts event	
end

# Unified2#read
# Parse a unified2 file and process the results.

Unified2.read('/var/log/snort/merged.log') do |event|

 puts event.protocol #=> "TCP"

 puts event.protocol.to_h #=> {:length=>379, :seq=>3934511163, :ack=>1584708129 ... }

end
```

## Requirements

 * bindata ~> 1.3.1
 * hexdump: ~> 0.1.0
 * packetfu: ~> 1.0.0
 * pcaprub: ~> 0.9.2

## Install

	`$ gem install unified2`

## Copyright

Copyright (c) 2011 Dustin Willis Webber

See LICENSE.txt for details.
