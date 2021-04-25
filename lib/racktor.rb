require_relative "./racktor/version.rb"
require_relative "./racktor/worker.rb"
require_relative "./racktor/server.rb"

# Ractor.make_shareable(URI::RFC2396_REGEXP::PATTERN::ALPHA)
# Ractor.make_shareable(URI::RFC2396_REGEXP::PATTERN::HEX)

module Racktor
  class Error < StandardError; end
  # Your code goes here...
end

require 'hanami/router'
module Hanami
  class Router
    def finalize!
      @router.send(:compile)
    end
  end
end

app = Hanami::Router.new do
  get '/', to: ->(env) { [200, {}, ['Welcome to Hanami::Router!']] }
end

Racktor::Server.run(host: 'localhost', port: 8080, cpu: 8) { app }
