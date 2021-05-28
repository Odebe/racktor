# frozen_string_literal: true

require 'socket'
require 'rack'
require 'etc'

module Racktor
  class Server
    CPU_COUNT = Etc.nprocessors

    Ractor.make_shareable(Rack::VERSION)

    def initialize(app, **options)
      @app = app
      @options = options
      @cpu_count = options[:workers] || CPU_COUNT
      @port = options[:port] || 8080
      @host = options[:host] || 'localhost'

      init_pipe
      init_workers
      # TODO: init_supervisor
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
      @workers ||= @cpu_count.times.map do
        Ractor.new(@pipe, @app) do |pipe, app|
          Racktor::Worker.new(pipe, app.compile!).run
        end
      end
    end
  end
end
