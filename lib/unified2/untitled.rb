require 'rubygems'
require 'goliath'
#require 'kernel'

class Hello < Goliath::API
  
  # reload code on every request in dev environment
  # use ::Rack::Reloader, 0 if Goliath.dev?

  def response(env)
    [200, {}, "Hello World"]
  end

end