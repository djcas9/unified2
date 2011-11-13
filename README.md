# Unified2

* [Homepage](http://github.com/mephux/unified2)
* [Issues](http://github.com/mephux/unified2/issues)
* [Documentation](http://rubydoc.info/gems/unified2/frames)
* [Email](mailto:dustin.webber at gmail.com)

## Description

A ruby interface for unified2 output. rUnified2 allows you to manipulate unified2 output for custom storage and/or analysis.

## Features

 * Monitor/Read unified2 logs & manipulate the data.
 * Numerous convenience methods
 * Simple & Intuitive to Use
 * Supports legacy unified2 formats and the most current as of snort 2.9.1.3
 * Packet data, headers, hexdumps and more.

## Examples

    require 'unified2'

    # Unified2 Configuration
    Unified2.configuration do

      # Sensor Configurations
      sensor :interface => 'en1',
        :name => 'Unified2 Example', :id => 3

      load :signatures, 'seeds/sid-msg.map'

      load :generators, 'seeds/gen-msg.map'
      
      load :classifications, 'seeds/classification.config'

    end

    Unified2.watch('seeds/unified2-current.log', :first) do |event|

      puts event.id

      puts event.severity

      puts event.classification.name

      puts event.signature.name

      event.extras.each do |extra|
        puts extra.name
        puts extra.value
      end

      event.packets.each do |packet|
        puts packet.ip_header
        puts packet.protocol.header
        puts packet.hexdump(:header => false, :width => 40)
      end

    end

## Requirements

 * bindata ~> 1.4.x
 * hexdump: ~> 0.2.x
 * packetfu: ~> 1.1.x

## TODO

 * Make both Event#watch and Event#read evented
 * User eventmachine to monitor the file i.e modify/delete/move/symlink

## Install

	`$ gem install unified2`

## Copyright

Copyright (c) 2011 Dustin Willis Webber

See LICENSE.txt for details.
