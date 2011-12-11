require "unified2/path"

#
# Unified2
#
module Unified2

  #
  # Paths
  #
  class Paths
    
    def initialize(paths, timestamp)
      @paths = []
      @read = []
      @watch = []

      paths.each do |p| 
        path = Path.new(p)
        next unless path.valid?

        if timestamp
          next if path.timestamp.to_i < timestamp
        end

        @paths.push path
      end

      @all = @paths.dup

      @paths = @paths.sort! do |a,b|
        a.timestamp <=> b.timestamp
      end

      if @paths.length > 1
        @watch = @paths.pop
        @read = @paths
      else
        @watch = @paths.first
      end
    end

    def read
      return @read unless block_given?
      @read.each do |path|
        yield path
      end      
    end

    def watch
      @watch
    end

    def all
      return @all unless block_given?
      @all.each do |path|
        yield path
      end
    end

  end # Class Paths End
  
end # Module Unified2 End
