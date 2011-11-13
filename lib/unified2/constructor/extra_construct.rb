require 'unified2/constructor/extra_data'
require 'unified2/constructor/extra_data_header'

module Unified2
  #
  # Unified2 Constructor Namespace
  #
  module Constructor
    #
    # Unified2 Construction
    #
    class ExtraConstruct < ::BinData::Record
      
      #
      # Rename record_header to header
      # to simplify and cut down on verbosity
      # 
      extra_data_header :header

      # 
      # Unified2 data types
      # 
      extra_data :data

      #
      # String padding
      # 
      #string :read_length => :padding_length

      #
      # Sometimes the data needs extra padding
      # 
      def padding_length
        if header.event_length > data.num_bytes
          header.event_length - data.num_bytes
        else
          0
        end
      end

    end # class ExtraConstruct
    
  end # module Construct

end # module Unified2

