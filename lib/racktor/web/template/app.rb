# frozen_string_literal: true

require_relative './router.rb'

module Racktor
  module Web
    module Template
      class App
        attr_reader :router

        def self.build(&block)
          app = new
          app.instance_exec(&block)
          app
        end

        def initialize
          @router = Router.new
        end

        def compile!
          ::Racktor::Web::App.build_from(self)
        end

        private

        def routes(&block)
          @router.instance_exec(&block)
        end
      end
    end
  end
end
