module Unified2

  class Signature

    attr_accessor :id, :revision, :name, :references

    def initialize(signature={})
      @id = signature[:signature_id] || 0
      @revision = signature[:revision]
      @name = signature[:name].strip
      @references = signature[:references]
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
