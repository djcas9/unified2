# file ||= File.open('sid-msg.map')
# @rules = {}
# count = 0
#
# file.each_line do |line|
#   id, body, *references = line.split(' || ')
#   @rules[id] = {
#     :id => id,
#     :name => body,
#     :references => references
#   }
# end
#

#require 'pathname'

module Unified2

  class Signature

    attr_accessor :signatures, :signature_count, :file, :path

    def initialize(file)
      @file = file
      @signatures = {}
      @signature_count = 0
      #@path = Pathname.new(@file.to_s)
    end

    def load
      @file.each_line do |line|
        id, body, *references = line.split(' || ')
        @signatures[id] = {
          :id => id,
          :name => body,
          :references => references
        }
      end
      
      @signatures
    end

  end
end
