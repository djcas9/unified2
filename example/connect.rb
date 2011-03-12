require 'rubygems'
require 'datamapper'
require 'dm-mysql-adapter'
require 'models'

class Connect
  
  def self.setup
    @connection = DataMapper.setup(:default, { 
      :adapter => "mysql",
      :host => "localhost",
      :database => "rUnified2",
      :username => "rUnified2",
      :password => "password"
    })
    DataMapper.finalize
    DataMapper.auto_upgrade!
  end
  
end
