# frozen_string_literal: true

require_relative './action.rb'
require_relative './router.rb'
require_relative './params_validator.rb'

require_relative './template/app.rb'

module Sorta
  module Http
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

          unless result.found?
            msg = "Cannot find #{env['REQUEST_METHOD']} action for route \"#{env['PATH_INFO']}\""
            logger.error msg
            return [404, {}, [msg]]
          end

          params = result.params
          params = result.payload[:schema].call(params) unless result.payload[:schema].nil?
          response = result.payload[:action].new(env).call(params)
          logger.info "#{response[0]} #{env['REQUEST_METHOD']} \"#{env['PATH_INFO']}\" #{result.payload[:action]} #{params.inspect}: #{response[2].join}"
          response
        rescue ParamsValidator::ValidationError => e
          logger.info "#{500} #{env['REQUEST_METHOD']} \"#{env['PATH_INFO']}\" #{result.payload[:action]} #{params.inspect}: #{e.message}"
          [500, {}, [e.message]]
        end

        private

        def logger
          Ractor.current[:logger]
        end

        def routes
          yield @router
        end
      end
    end
  end
end
