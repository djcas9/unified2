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

require 'unified2/primitive/ipv4'

module Unified2
  
  class EventIP4 < ::BinData::Record
    
    endian :big

    uint32    :sensor_id
    uint32    :event_id
    uint32    :event_second
    uint32    :event_microsecond
    uint32    :signature_id
    uint32    :generator_id
    uint32    :signature_revision
    uint32    :classification_id
    uint32    :priority_id
    ipv4      :ip_source
    ipv4      :ip_destination
    uint16    :sport_itype
    uint16    :dport_icode
    uint8     :protocol
    uint8     :packet_action
  end

end
