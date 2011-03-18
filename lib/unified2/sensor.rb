module Unified2
  class Sensor
    
    attr_accessor :id, :hostname, :interface, :name, :checksum
    
    #
    # Initialize sensor object
    # 
    # @param [Hash] options Sensor hash attributes
    # 
    # @option options [Integer] :id Sensor id
    # @option options [String] :name Sensor name
    # @option options [String] :interface Sensor interface
    # 
    def initialize(options={})
      @id = options[:id] || 0
      @name = options[:name] || ""
      @hostname ||= Socket.gethostname
      @interface ||= options[:interface] || nil
      @checksum = nil
    end
    
    #
    # Update
    # 
    # @param [Hash] attributes Sensor attributes
    # 
    # @option attributes [Integer] :id Sensor id
    # @option attributes [String] :hostname Sensor hostname
    # @option attributes [String] :name Sensor name
    # @option attributes [String] :interface Sensor interface
    # 
    def update(attributes={})
      return self if attributes.empty?
      
      attributes.each do |key, value|
        next unless self.respond_to?(key.to_sym)
        instance_variable_set(:"@#{key}", value)
      end
      
      self
    end
    
  end
end