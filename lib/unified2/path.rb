require "date"
require "pathname"

#
# Unified2
#
module Unified2

  #
  # Path
  #
  class Path
    
    def initialize(path)
      @path = Pathname.new(path)
    end

    def to_s
      @path.to_s
    end

    def basename
      @path.basename
    end

    def timestamp
      match = @path.to_s.match(/\d{10}/).to_s
      timestamp = if !match.to_i.zero?
        Time.at(match.to_i)
      else
        false
      end
    end

    def valid?
      timestamp
    end

  end # Class Paths End
  
end # Module Unified2 End

