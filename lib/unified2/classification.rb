module Unified2
  class Classification

    attr_accessor :id, :name, :short, :severity

    def initialize(classification={})
      @id = classification[:classification_id]
      @name = classification[:name]
      @short = classification[:short]
      @severity = classification[:severity]
    end

  end
end
