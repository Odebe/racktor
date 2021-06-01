require_relative '../lib/sorta/http.rb'

HOST = 'localhost'
PORT = 8080
WORKERS_COUNT = 2

module Actions
  class Root
    include Sorta::Http::Web::Action

    def call
      logger.info 'root test log'
      "Welcome to RACKtor::Web!"
    end
  end

  class Hello
    include Sorta::Http::Web::Action

    def call(params)
      "Hello, #{params[:name]}"
    end
  end

  module Calc
    class Plus
      include Sorta::Http::Web::Action

      def call(params)
        params[:num1] + params[:num2]
      end
    end

    class Minus
      include Sorta::Http::Web::Action

      def call(params)
        params[:num1] - params[:num2]
      end
    end
  end
end

hello_schema = Sorta::Http::Web::ParamsValidator.build do
  param :name, type: String
end

calc_schema = Sorta::Http::Web::ParamsValidator.build do
  param :num1, type: Integer
  param :num2, type: Integer
end

app = Sorta::Http::Web::Template::App.build do
  routes do
    get '/', to: Actions::Root
    get '/hello/:name', to: Actions::Hello, schema: hello_schema

    namespace :calc do
      namespace :minus do
        get '/:num1/:num2', to: Actions::Calc::Minus, schema: calc_schema
      end

      namespace :plus do
        get '/:num1/:num2', to: Actions::Calc::Plus, schema: calc_schema
      end
    end
  end
end

server = Sorta::Http::Server.new(app,host: HOST, port: PORT, workers: WORKERS_COUNT, logger: Sorta::Http::Logger.new)
server.run