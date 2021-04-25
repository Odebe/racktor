# frozen_string_literal: true

module Racktor
  class Worker
    STATUS_CODES = { 200 => 'OK', 500 => 'Internal Server Error' }.freeze

    attr_reader :pipe, :app

    def initialize(pipe, app)
      @pipe = pipe
      @app = app
    end

    def run
      loop do
        socket = pipe.take
        request = socket.gets

        if request.nil?
          socket.close
          next
        end

        env = new_env(*request.split)
        status, headers, body = app.call(env)

        socket.print "HTTP/1.1 #{status} #{STATUS_CODES[status]}\r\n"
        headers.each do |k, v|
          socket.print "#{k}: #{v}\r\n"
        end
        socket.print "Connection: close\r\n"
        socket.print "\r\n"

        if body.is_a?(String)
          socket.print body
        else
          body.each do |chunk|
            socket.print chunk
          end
        end

        socket.close
      end
    end

    private

    def new_env(method, location, *args)
      {
        'REQUEST_METHOD'   => method,
        'SCRIPT_NAME'      => '',
        'PATH_INFO'        => location,
        'QUERY_STRING'     => location.split('?').last,
        'SERVER_NAME'      => 'localhost',
        'SERVER_POST'      => '8080',
        'rack.version'     => Rack.version.split('.'),
        'rack.url_scheme'  => 'http',
        'rack.input'       => StringIO.new(''),
        'rack.errors'      => StringIO.new(''),
        'rack.multithread' => false,
        'rack.run_once'    => false
      }
    end
  end
end
