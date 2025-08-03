# frozen_string_literal: true

require_relative "./request"
require "async"
require "async/http/server"
require "async/http/endpoint"
require "async/http/protocol/http1"

module Guaraci
  # HTTP server that handles incoming requests with a simple block-based API.
  # Built on top of Async::HTTP for high performance and non-blocking I/O.
  #
  # @example Basic server
  #   Guaraci::Server.run do |request|
  #     Guaraci::Response.ok { |r| r.json({message: "Hello World"}) }.render
  #   end
  #
  # @example Pattern Matching Routing (What I recommend)
  #   Guaraci::Server.run do |request|
  #     case [request.method, request.path_segments]
  #     in ['GET', []]
  #       Guaraci::Response.ok { |r| r.html("<h1>Welcome!</h1>") }.render
  #     in ['GET', ['health']]
  #       Guaraci::Response.ok { |r| r.json({ status: "healthy" }) }.render
  #     in ['GET', ['api', 'users']]
  #       Guaraci::Response.ok { |r| r.json({ users: [] }) }.render
  #     in ['GET', ['api', 'users', user_id]]
  #       Guaraci::Response.ok { |r| r.json({ user: { id: user_id } }) }.render
  #     in ['POST', ['api', 'users']]
  #       user_data = request.params
  #       Guaraci::Response.new(201) { |r| r.json({ created: user_data }) }.render
  #     else
  #       Guaraci::Response.new(404) { |r| r.json({ error: "Not Found" }) }.render
  #     end
  #   end
  #
  # @author Guilherme Silva
  # @since 1.0.0
  # @see Guaraci::Request
  # @see Guaraci::Response
  # @see https://github.com/socketry/async-http Async::HTTP documentation
  class Server
    # Creates a new server instance with the given handler block.
    #
    # @param block [Proc] The request handler block that will be called for each HTTP request
    # @yield [request] Block to handle incoming HTTP requests
    # @yieldparam request [Guaraci::Request] The wrapped HTTP request object
    # @yieldreturn [Protocol::HTTP::Response] Response object from calling .render on a Guaraci::Response
    #
    # @example
    #   server = Guaraci::Server.new do |request|
    #     case request.method
    #     when "GET"
    #       Guaraci::Response.ok { |r| r.text("Hello World") }.render
    #     else
    #       Guaraci::Response.new(405) { |r| r.text("Method Not Allowed") }.render
    #     end
    #   end
    def initialize(&block)
      @handler = block
    end

    # Process an incoming HTTP request.
    #
    # This method is called by the Async::HTTP server for each incoming request.
    # It wraps the raw request in a {Guaraci::Request} object and executes the
    # configured handler block.
    #
    # @param request [Object] Raw HTTP request from Async::HTTP
    # @return [Protocol::HTTP::Response] The response object returned by the handler
    #
    # @note This method is typically called internally by the server infrastructure
    #   and not directly by user code.
    # @see https://github.com/socketry/async-http/blob/main/lib/async/http/server.rb Async::HTTP::Server
    def call(request)
      request = Request.new(request)

      instance_exec(request, &@handler)
    end

    # Starts an HTTP server on the specified host and port.
    # The server runs indefinitely until stopped.
    #
    # @param host [String] the host to bind to
    # @param port [Integer] the port to listen on
    # @param block [Proc] the request handler block
    def self.run(host: "localhost", port: 8000, &block)
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
