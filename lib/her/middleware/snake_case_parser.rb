module Her
  module Middleware
    class SnakeCaseParser < Faraday::Response::Middleware

      def snake_caseify(val)
        case val
        when Array
          val.map { |v| call(v) }
        when Hash
          val.deep_transform_keys { |k| k.to_s.underscore }
        else
          val
        end
      end

      def on_complete(env)
        json = snake_caseify(MultiJson.load(env[:body]))

        errors = json.delete('errors') || {}
        metadata = json.delete('metadata') || {}
        env[:body] = {
          data: json,
          errors: errors,
          metadata: metadata
        }
      end
    end
  end
end
