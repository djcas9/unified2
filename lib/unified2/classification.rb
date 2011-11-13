#
# Unified2
#
module Unified2
  #
  # Classification
  # 
  class Classification

    attr_accessor :id, :name, :short, :severity
    
    #
    # Initialize classification
    # 
    # @param [Hash] classification Classification attributes
    # 
    # @option classification [Integer] :classification_id Classification id
    # @option classification [String] :name Classification name
    # @option classification [String] :short Classification short name
    # @option classification [String] :severity Classification severity id
    # 
    def initialize(classification={})
      @id = classification[:classification_id]
      @name = classification[:name]
      @short = classification[:short]
      @severity = classification[:severity]
    end

    #
    # String
    #
    # @return [String] Signature name
    #
    def to_s
      @name
    end

  end # class Classification

end # module Unified2
