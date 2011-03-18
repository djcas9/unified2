module Unified2

  class Signature

    attr_accessor :id, :generator, :revision, :name

    #
    # Initialize signature object
    # 
    # @param [Hash] signature Signature hash attributes
    # 
    def initialize(signature={})
      @id = signature[:signature_id] || 0
      @generator = signature[:generator_id]
      @revision = signature[:revision]
      @name = signature[:name].strip
      @blank = signature[:blank]
    end

    def blank?
      @blank
    end

    def references
      @references
    end

  end
end
