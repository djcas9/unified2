module Unified2
  class Classification

    attr_accessor :id, :name, :short, :priority

    def initialize(classification={})
      @id = classification[:classification_id]
      @name = classification[:name]
      @short = classification[:short]
      @priority = classification[:priority]
    end

  end
end
