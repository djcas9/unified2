module Unified2
  #
  # Signature
  #
  class Signature
    
    attr_accessor :id, :generator, :revision, :name, :blank

    #
    # Initialize signature object
    # 
    # @param [Hash] signature Signature hash attributes
    # 
    # @option signature [Integer] :signature_id Signature id
    # @option signature [Integer] :generator_id Generator id
    # @option signature [Integer] :revision Signature revision
    # @option signature [Integer] :name Signature name
    # @option signature [true, false] :blank Signature exists
    # 
    def initialize(signature={})
      @id = signature[:signature_id] || 0
      @generator = signature[:generator_id]
      @revision = signature[:revision]
      @name = signature[:name].strip
      @blank = signature[:blank] || false
    end

    #
    # Blank?
    # 
    # @return [true, false] 
    #   Return true if signature exists
    # 
    def blank?
      @blank
    end

    #
    # References
    # 
    # @return [Array<String,String>] Signature references
    # 
    def references
      @references
    end

  end
end
