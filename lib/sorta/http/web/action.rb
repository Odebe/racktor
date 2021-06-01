# frozen_string_literal: true

module Sorta
  module Http
    module Web
      module Action
        def self.included(mod)
          mod.prepend PrependMethods
        end

        module PrependMethods
          def initialize(env)
            @env = env
          end

          def call(params = [])
            result = params.any? ? super(params) : super()
            [200, {}, [result]]
          rescue => e
            [500, {}, [e.message, e.backtrace.join("\n")]]
          end
        end

        private

        # TODO: передавать как зависимость
        def logger
          Ractor.current[:logger]
        end
      end
    end
  end
end
