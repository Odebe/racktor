# frozen_string_literal: true

module Sorta
  module Http
    module Web
      class ParamsValidator
        class ValidationError < StandardError; end

        def self.build(&block)
          obj = new
          obj.instance_exec(&block)
          obj
        end

        def initialize
          @rules = {}
        end

        def param(name, type:)
          @rules[name] = type
        end

        def call(params)
          errors = []
          result = @rules.each_with_object({}) do |(key, klass), acc|
            acc[key] = Kernel.send(klass.name, params[key.to_s])
          rescue => e
            errors << "#{e.message}"
          end
          raise ValidationError.new(errors.join("\n")) if errors.any?

          result
        end
      end
    end
  end
end
