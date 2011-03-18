require 'spec_helper'
require 'unified2'

describe Event do

  before(:all) do
    Unified2.configuration do
      sensor :interface => 'en1',
        :name => 'Example Sensor',
        :hostname => 'W0ots.local'

      load :signatures, 'example/seeds/sid-msg.map'
      load :generators, 'example/seeds/gen-msg.map'
      load :classifications, 'example/seeds/classification.config'
    end
  end
  
  
end