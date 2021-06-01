# frozen_string_literal: true

module Sorta
  module Http
    module Web
      class Router
        def self.build_from(template)
          router = new
          template.routes.each do |route|
            router.send(route[0], route[1], to: route[2], schema: route[3])
          end
          router
        end

        def initialize
          @tree = Radix::Tree.new
        end

        def find(env)
          key = File.join(env['PATH_INFO'], env['REQUEST_METHOD'].downcase)
          @tree.find key
        end

        %i[get post put delete].each do |method|
            module_eval(<<~RUBY, __FILE__, __LINE__ + 1)
            def #{method}(path, to:, schema: nil)
              add_route(path, method: :#{method}, to: to, schema: schema)
            end
          RUBY
        end

        private

        def add_route(path, method:, to:, schema:)
          raise 'routing error' if to.nil?

          key = File.join(path, method.to_s.downcase)
          @tree.add key, { action: to, schema: schema }
          true
        end
      end
    end
  end
end
