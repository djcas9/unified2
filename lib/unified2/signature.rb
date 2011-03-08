module Unified2

  class Signature

    attr_accessor :id, :name, :references

    def initialize(signature={})
      @id = signature[:signature_id] || 0
      @name = signature[:name] || "Unknow Signature #{@id}"
      @references = signature[:references] || []
    end

    def id
      @id.to_i
    end

    def name
      return @name.strip if @name
      @name
    end

    def references
      @references
    end

  end
end
