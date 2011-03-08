#
# rUnified2 - A ruby interface for unified2 output.
# 
# Copyright (c) 2010 Dustin Willis Webber (dustin.webber at gmail.com)
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
#

require 'bindata'
# http://cvs.snort.org/viewcvs.cgi/snort/src/output-plugins/spo_unified2.c?rev=1.3&content-type=text/vnd.viewcvs-markup

require 'unified2/construct'
require 'unified2/event'
require 'unified2/exceptions'
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
      raise FileNotFound, "Error - #{path} not found."
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

  def self.watch(path, event_id=false, &block)

    unless File.exists?(path)
      raise FileNotFound, "Error - #{path} not found."
    end

    if File.readable?(path)
      io = File.open(path)

      if event_id
        @event = Event.new(event_id.to_i)
      else
        
        until io.eof?
          event = Unified2::Construct.read(io)
        end
        event_id = event.data.event_id
        
        # first_open = File.open(path)
        # first_event = Unified2::Construct.read(first_open)
        # first_open.close
        @event = Event.new(event_id)
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

  def self.read(path, options={}, &block)
    limit = options[:limit] ? (options[:limit] * 2) : 10 # 5 records
    count = 0

    unless File.exists?(path)
      raise("Error - #{path} not found.")
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
