require_relative '../lib/racktor.rb'

HOST = 'localhost'
PORT = 8080
WORKERS_COUNT = 2

module Actions
  class Root
    include Racktor::Web::Action

    def call
      "Welcome to RACKtor::Web!"
    end
  end

  class Hello
    include Racktor::Web::Action

    def call(params)
      "Hello, #{params[:name]}"
    end
  end

  module Calc
    class Plus
      include Racktor::Web::Action

      def call(params)
        params[:num1] + params[:num2]
      end
    end

    class Minus
      include Racktor::Web::Action

      def call(params)
        params[:num1] - params[:num2]
      end
    end
  end
end

hello_schema = Racktor::Web::ParamsValidator.build do
  param :name, type: String
end

calc_schema = Racktor::Web::ParamsValidator.build do
  param :num1, type: Integer
  param :num2, type: Integer
end

app = Racktor::Web::Template::App.build do
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

server = Racktor::Server.new(app,host: HOST, port: PORT, workers: WORKERS_COUNT)
server.run