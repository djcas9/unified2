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

module Unified2
  module Primitive
    
    class IPV4 < ::BinData::Primitive
      array :octets, :type => :uint8, :initial_length => 4

      def set(val)
        ints = val.split(/\./).collect { |int| int.to_i }
        self.octets = ints
      end

      def get
        self.octets.collect { |octet| "%d" % octet }.join(".")
      end

    end
    
  end
end