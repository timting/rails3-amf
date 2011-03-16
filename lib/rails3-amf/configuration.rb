module Rails3AMF
  class Configuration
    class << self
      def populate config
        @config = config
      end

      def reset
        Rails3AMF::Configuration.new
      end

      def method_missing name, *args
        @config.send(name, *args)
      end
    end

    def initialize
      @data = {
        :gateway_path => "/amf",
        :auto_class_mapping => false
      }
      @param_mappings = {}

      # Make config available globally
      Rails3AMF::Configuration.populate self
    end

    def class_mapping &block
      RocketAMF::ClassMapper.define(&block)
    end

    def map_params options
      @param_mappings[options[:controller]+"#"+options[:action]] = options[:params]
    end

    def mapped_params controller, action, arguments
      mapped = {}
      if mapping = @param_mappings[controller+"#"+action]

        arguments.each_with_index do |arg, i| 
          if mapping[i].is_a? String

            target = mapped

            last_target = nil
            last_key = nil

            path = mapping[i].split('.')
            path.each do |key|
              target[key.to_sym] = {} unless target[key.to_sym].present?

              last_target = target
              last_key = key.to_sym

              target = target[key.to_sym]
            end
            last_target[last_key] = arg

          else
            mapped[mapping[i]] = arg
          end
        end
      end
      mapped
    end

    def method_missing name, *args
      if name.to_s =~ /(.*)=$/
        @data[$1.to_sym] = args.first
      else
        @data[name]
      end
    end
  end
end
