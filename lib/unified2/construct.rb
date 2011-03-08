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

require 'unified2/event_ip4'
require 'unified2/event_ip6'
require 'unified2/record_header'
require 'unified2/packet'

module Unified2
  
  class Construct < ::BinData::Record
    record_header :header
    
    choice :data, :selection => :type_selection do
      packet "packet"
      event_ip4  "ev4"
      event_ip6 "ev6"
    end

    string :read_length => :padding_length  # padding

    #define UNIFIED2_EVENT 1
    #define UNIFIED2_PACKET 2
    #define UNIFIED2_IDS_EVENT 7
    #define UNIFIED2_EVENT_EXTENDED 66
    #define UNIFIED2_PERFORMANCE 67
    #define UNIFIED2_PORTSCAN 68
    #define UNIFIED2_IDS_EVENT_IPV6 72
    def type_selection
      case header.u2type.to_i
      when 2
        "packet"
      when 7
        "ev4"
      when 72
        "ev6"
      else
        "unknown type #{header.u2type}"
      end
    end

    # sometimes the data needs extra padding
    def padding_length
      if header.u2length > data.num_bytes
        header.u2length - data.num_bytes
      else
        0
      end
    end
  end
  
end