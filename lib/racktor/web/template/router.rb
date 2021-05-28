# frozen_string_literal: true

module Racktor
  module Web
    module Template
      class Router
        attr_reader :routes

        def initialize
          @routes = []
          @prefix = ''
        end

        %i[get post put delete].each do |method|
          module_eval(<<~RUBY, __FILE__, __LINE__ + 1)
            def #{method}(path, to:, schema: nil)
              @routes << [:#{method}, with_prefix(path), to, schema]
            end
          RUBY
        end

        private

        def with_prefix(path)
          File.join('/', @prefix, path)
        end

        def namespace(name, &block)
          old_prefix = @prefix
          @prefix = with_prefix(name.to_s)
          instance_exec(&block)
        ensure
          @prefix = old_prefix
        end
      end
    end
  end
end
