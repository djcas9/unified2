module Unified2
  class ConfigFile

    attr_accessor :type, :path, :md5, :data

    #
    # Initialize configuration file
    # 
    # @param [String, Symbol] type Configuration file type
    # @param [String] path Configuration file path
    # 
    def initialize(type, path)
      @type = type
      @path = path
      @data = {}
      @md5 = Digest::MD5.hexdigest(@path)
      import
    end

    private
      
      #
      # Configuration Import
      # 
      # Parse the configuration files and store
      # them in memory as a hash.
      # 
      def import
        file = File.open(@path)
        
        case @type.to_sym
        when :classifications

          count = 0
          file.each_line do |line|
            next if line[/^\#/]
            next unless line[/^config\s/]
            count += 1

            data = line.gsub!(/config classification: /, '')
            short, name, severity = data.to_s.split(',')

            @data[count.to_s] = {
              :short => short,
              :name => name,
              :severity_id => severity.to_i
            }
          end

        when :generators

          file.each_line do |line|
            next if line[/^\#/]
            generator_id, alert_id, name = line.split(' || ')
            id = "#{generator_id}.#{alert_id}"

            @data[id] = {
              :generator_id => generator_id,
              :name => name,
              :signature_id => alert_id
            }
          end

        when :signatures

          file.each_line do |line|
            next if line[/^\#/]
            id, body, *reference_data = line.split(' || ')
            
            references = {}
            reference_data.each do |line|
              key, value = line.split(',')
              if references.has_key?(key.downcase.to_sym)
                references[key.downcase.to_sym] << value
              else
                references[key.downcase.to_sym] = [value]
              end
            end
            
            @data[id] = {
              :signature_id => id,
              :name => body,
              :generator_id => 1
            }
          end

        end
      end

  end # class ConfigFile

end # module Unified2