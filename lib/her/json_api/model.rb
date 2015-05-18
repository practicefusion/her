module Her
  module JsonApi
    module Model
      
      def self.included(klass)
        klass.class_eval do
          include Her::Model

          method_for :update, :patch

          @type = name.demodulize.tableize
          
          def self.parse(data)
            data.fetch(:attributes).merge(data.slice(:id))
          end

          def self.to_params(attributes, changes={})
            request_data = { type: @type }.tap { |request_body| 
              attrs = attributes.dup.symbolize_keys.tap { |filtered_attributes|
                if her_api.options[:send_only_modified_attributes]
                  filtered_attributes = changes.symbolize_keys.keys.inject({}) do |hash, attribute|
                    hash[attribute] = filtered_attributes[attribute]
                    hash
                  end
                end
              }
              request_body[:id] = attrs.delete(:id) if attrs[:id]
              request_body[:attributes] = attrs
            }
            { data: request_data }
          end

          def self.type(type_name)
            @type = type_name.to_s
          end

          def type
            self.class.instance_variable_get('@type')
          end
        end
      end
    end
  end
end
