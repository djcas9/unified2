module Unified2
  class Sensor
    
    attr_accessor :id, :hostname, :interface, :name, :checksum
    
    def initialize(options={})
      @id = options[:id] || 0
      @name = options[:name] || ""
      @hostname ||= Socket.gethostname
      @interface ||= options[:interface] || nil
      @checksum = nil
    end
    
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