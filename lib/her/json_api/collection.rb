module Her
  module JsonApi
    module Collection
      extend ActiveSupport::Concern

      include Enumerable
      include Her::Model::HTTP
      include Her::Model::Paths

      def initialize(*models)
        @models = models.flatten
      end
        
      def each &block
        @models.each do |model|
          if block_given?
            block.call(model)
          else
            yield model
          end
        end
      end

      def create
        self.class.create(*@models)
      end

      def update
        self.class.update(*@models)
      end

      module ClassMethods
        def create(*models)
          # for now only handle homogeneous collections
          model_klass = models.first.class
          params = models.map { |model|
            {
              type: model.type,
              attributes: model.attributes.symbolize_keys.except(:id, :type),
            }
          }
          post_raw(model_klass.collection_path,  data: params) do |parsed_data, response|
            created_models = parsed_data.fetch(:data).map { |elt|
              model_klass.new(model_klass.parse(elt))
            }
            new(created_models)
          end
        end

        def update(*models)
          # for now only handle heterogeneous collections
          model_klass = models.first.class
          params = models.map { |model|
            {
              id: model.id,
              type: model.type,
              attributes: model.attributes.symbolize_keys.except(:id, :type),
            }
          }
          patch_raw(model_klass.collection_path,  data: params) do |parsed_data, response|
            updated_models = parsed_data.fetch(:data).map { |elt|
              model_klass.new(model_klass.parse(elt))
            }
            new(updated_models)
          end
        end
      end

      def self.included(klass)
        klass.use_api Her::API.default_api

        klass.send(:extend, ClassMethods)
      end
    end
  end
end
