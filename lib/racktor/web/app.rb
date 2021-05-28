# frozen_string_literal: true

require_relative './action.rb'
require_relative './router.rb'
require_relative './params_validator.rb'

require_relative './template/app.rb'

module Racktor
  module Web
    class App
      def self.build_from(template)
        dependencies = [
          Router.build_from(template.router)
        ]
        new(*dependencies)
      end

      def self.build(&block)
        app = new
        app.instance_exec(&block)
        app
      end

      def initialize(router = Router.new)
        @router = router
      end

      def call(env)
        result = @router.find(env)
        puts result.inspect
        return [404, {}, ["Cannot find #{env['REQUEST_METHOD']} action for route #{env['PATH_INFO']}"]] unless result.found?

        params = result.params
        params = result.payload[:schema].call(params) unless result.payload[:schema].nil?
        result.payload[:action].new(env).call(params)
      end

      private

      def routes
        yield @router
      end
    end
  end
end

