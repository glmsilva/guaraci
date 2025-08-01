# frozen_string_literal: true

require_relative './request.rb'
require "async"
require "async/http/server"
require "async/http/endpoint"
require "async/http/protocol/http1"
require "json"

module Guaraci
  class Server
    def initialize(&block)
      @handler = block
    end

    def call(request)
      request = Request.new(request)

      instance_exec(request, &@handler)
    end

    def self.run(host: 'localhost', port: 8000, &block)
      app = new(&block)
      url = "http://#{host}:#{port}"

      Async do
        endpoint = Async::HTTP::Endpoint.parse(url)
        server = Async::HTTP::Server.new(app.method(:call), endpoint, protocol: Async::HTTP::Protocol::HTTP1)

        puts "Guaraci running on #{url}"
        server.run
      end
    end
  end
end
