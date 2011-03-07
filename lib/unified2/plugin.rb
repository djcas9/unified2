module Unified2
  class Plugin
    attr_accessor :plugin, :host, :username, :password
    
    def self.initialize(plugin, options)
      @plugin = plugin.to_sym
      @host = options[:host] || 'localhost'
      @username = options[:username]
      @password = options[:password]
    end

  end
end
