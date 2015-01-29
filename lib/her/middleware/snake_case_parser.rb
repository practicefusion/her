module Her
  module Middleware
    class SnakeCaseParser < Faraday::Response::Middleware

      def snake_caseify(val)
        case val
        when Array
          val.map { |v| snake_caseify(v) }
        when Hash
          Hash[val.map { |k, v| [k.to_s.underscore, snake_caseify(v)] }]
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
