# frozen_string_literal: true

require "json"
require "protocol/http"

module Guaraci
  # HTTP response builder for the Guaraci web framework.
  #
  # It handles the conversion between high-level Ruby objects and the low-level Protocol::HTTP
  # objects required by the HTTP server.
  #
  # @example Basic JSON response
  #   response = Guaraci::Response.ok do |res|
  #     res.json({ message: "Hello World", status: "success" })
  #   end
  #   response.render #=> Protocol::HTTP::Response
  #
  # @example HTML response with custom status
  #   response = Guaraci::Response.new(201) do |res|
  #     res.html("<h1>Resource Created</h1>")
  #   end
  #   response.render
  #
  # @example Plain text response
  #   response = Guaraci::Response.ok do |res|
  #     res.text("Simple message")
  #   end
  #   response.render
  #
  # @see https://github.com/socketry/protocol-http Protocol::HTTP documentation
  # @see https://github.com/socketry/async-http Async::HTTP documentation
  # @author Guilherme SIlva
  # @since 1.0.0
  class Response
    # The HTTP status code for this response.
    #
    # Common status codes:
    # - 200: OK (successful request)
    # - 201: Created (resource created successfully)
    # - 400: Bad Request (client error)
    # - 404: Not Found (resource not found)
    # - 500: Internal Server Error (server error)
    #
    # @return [Integer] HTTP status code (e.g., 200, 404, 500)
    # @see https://tools.ietf.org/html/rfc7231#section-6 HTTP status code definitions
    # @example
    #   response.status #=> 200
    attr_reader :status

    # The HTTP response body containing the actual content.
    #
    # The body is automatically converted to {Protocol::HTTP::Body::Buffered}
    # format when content is written using {#write}, {#json}, {#html}, or {#text}.
    # This ensures compatibility with Async::HTTP's streaming requirements.
    #
    # @return [Protocol::HTTP::Body::Buffered] HTTP response body
    # @see https://github.com/socketry/protocol-http/blob/main/lib/protocol/http/body/buffered.rb Protocol::HTTP::Body::Buffered
    # @example
    #   response.body.read #=> '{"message":"Hello World"}'
    attr_reader :body

    # The HTTP response headers collection.
    #
    # Headers are stored as {Protocol::HTTP::Headers} objects
    #
    # @return [Protocol::HTTP::Headers] HTTP response headers
    # @see https://github.com/socketry/protocol-http/blob/main/lib/protocol/http/headers.rb Protocol::HTTP::Headers
    # @example
    #   response.headers['content-type'] #=> 'application/json'
    #   response.headers['content-length'] #=> '25'
    attr_reader :headers

    # Initialize a new HTTP response with the specified status code.
    #
    # Creates a new response instance with empty headers and body.
    # The headers are initialized as {Protocol::HTTP::Headers} and the
    # body starts as an empty buffered body until content is written.
    #
    # @param status [Integer] HTTP status code
    # @raise [ArgumentError] if status is not a valid HTTP status code
    #
    # @example Creating different response types
    #   success = Guaraci::Response.new(200)    # OK
    #   not_found = Guaraci::Response.new(404)  # Not Found
    #   error = Guaraci::Response.new(500)      # Internal Server Error
    #
    # @example With content
    #   response = Guaraci::Response.new(201)
    #   response.json({ id: 123, created: true })
    def initialize(status)
      @status = status
      @headers = Protocol::HTTP::Headers.new
      @body = default_body
    end

    # Create a successful HTTP response (200 OK).
    #
    # This is a convenient factory method for creating successful responses.
    # It automatically sets the status to 200 and yields the response instance
    # to the provided block for content configuration.
    #
    # @yield [response] Block to configure the response content and headers
    # @yieldparam response [Response] The response instance to configure
    # @return [Response] The configured response instance with status 200
    #
    # @example Without block (empty 200 response)
    #   response = Guaraci::Response.ok
    #   response.status #=> 200
    #
    # @example With configuration block
    #   response = Guaraci::Response.ok do |res|
    #     res.json({ message: "Operation successful!" })
    #   end
    #
    # @example Method chaining after creation
    #   response = Guaraci::Response.ok
    #   response.json({ data: [1, 2, 3] })
    def self.ok
      res = new(200)
      yield(res) if block_given?
      res
    end

    # Write content to the response body with specified content type.
    #
    # This is the base method used by all other content methods (json, html, text).
    # It automatically converts the content to {Protocol::HTTP::Body::Buffered} format
    # required by Async::HTTP and sets the appropriate Content-Type header.
    #
    # @param content [String, Array] Content to write to response body
    # @param content_type [String] MIME type for the response
    # @return [Response] Self for method chaining
    #
    # @see Protocol::HTTP::Body::Buffered
    def write(content, content_type: "application/json")
      @headers["content-type"] = content_type
      @body = Protocol::HTTP::Body::Buffered.wrap(content)
      self
    end

    # Write JSON content to the response body.
    #
    # Automatically serializes the provided object to JSON using {JSON.dump}
    #
    # @param content [Object] Any object that can be serialized to JSON
    # @return [Response] Self for method chaining
    #
    # @example Hash object
    #   response.json({ message: "Hello", data: [1, 2, 3] })
    def json(content)
      write(JSON.dump(content))
    end

    # Write HTML content to the response body.
    #
    # Sets the Content-Type to "text/html" and writes the provided HTML string.
    # No HTML validation or processing is performed - the content is sent as-is.
    #
    # @param content [String] HTML content
    # @return [Response] Self for method chaining
    #
    # @example Simple HTML
    #   response.html("<h1>Welcome</h1>")
    #
    # @example Complete HTML document
    #   response.html(<<~HTML)
    #     <!DOCTYPE html>
    #     <html>
    #       <head><title>My Page</title></head>
    #       <body><h1>Hello World!</h1></body>
    #     </html>
    #   HTML
    def html(content)
      write(content, content_type: "text/html")
    end

    # Write plain text content to the response body.
    #
    # Sets the Content-Type to "text/plain" and writes the provided text.
    #
    # @param content [String] Plain text content
    # @return [Response] Self for method chaining
    #
    # @example Simple text
    #   response.text("Hello, World!")
    #
    # @example Multi-line text
    #   response.text("Line 1\nLine 2\nLine 3")
    def text(content)
      write(content, content_type: "text/plain")
    end

    # Convert the response to a Protocol::HTTP::Response object.
    #
    # This method transforms the Guaraci::Response into the low-level response format
    # required by the Async::HTTP server. It ensures that all components (status, headers, body)
    # are properly formatted for HTTP transmission.
    #
    # The returned object contains:
    # - version: HTTP version (automatically determined by Protocol::HTTP)
    # - status: Integer HTTP status code
    # - headers: Protocol::HTTP::Headers instance with all response headers
    # - body: Protocol::HTTP::Body::Buffered instance containing the response content
    #
    # @return [Protocol::HTTP::Response] A complete HTTP response object ready for transmission
    # @see https://github.com/socketry/protocol-http/blob/main/lib/protocol/http/response.rb Protocol::HTTP::Response
    # @see https://github.com/socketry/async-http Async::HTTP server documentation
    #
    # @example Basic usage
    #   response = Guaraci::Response.ok { |r| r.json({message: "Hello"}) }
    #   http_response = response.render
    #   http_response.status #=> 200
    #   http_response.headers['content-type'] #=> 'application/json'
    def render
      Protocol::HTTP::Response.new(nil, @status, @headers, @body)
    end

    private

    # @return [Protocol::HTTP::Body::Buffered] An empty body
    # @see Protocol::HTTP::Body::Buffered.wrap
    def default_body
      Protocol::HTTP::Body::Buffered.wrap("")
    end
  end
end
