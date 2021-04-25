# frozen_string_literal: true

require 'socket'
require 'rack'
require 'stringio'
require 'etc'
require 'uri'

module Racktor
  class Server
    CPU_COUNT = Etc.nprocessors
    FINALIZE_CLASSES = ['Hanami::Router'].freeze

    Ractor.make_shareable(Rack::VERSION)
    Ractor.make_shareable(URI::DEFAULT_PARSER)

    def self.run(**options, &block)
      new(block, **options).run
    end

    def initialize(app_gen, **options)
      @app_gen = app_gen
      @options = options
      @cpu_count = options[:cpu] || CPU_COUNT
      @port = options[:port] || 8080
      @host = options[:host] || 'localhost'

      init_pipe
      init_workers
    end

    def run
      tcp_server = TCPServer.new(@host, @port)
      loop { @pipe.send(tcp_server.accept, move: true) }
    end

    private

    def init_pipe
      @pipe = Ractor.new do
        loop { Ractor.yield(Ractor.receive, move: true) }
      end
    end

    def init_workers
      @workers ||=
        begin
          @cpu_count.times.map do
            app = @app_gen.call
            app.finalize! if need_to_finalize?(app)
            Ractor.make_shareable(app)

            Ractor.new(@pipe, app) do |pipe, app|
              Racktor::Worker.new(pipe, app).run
            end
          end
        end
    end

    # TODO: не самый лучший подход, как-нибудь починить
    def need_to_finalize?(app)
      return unless FINALIZE_CLASSES.include? app.class.name

      app.finalize!
    end
  end
end
