# frozen_string_literal: true

require "json"

module Guaraci
  # Represents the requests wrapper that provides convenient access to request data.
  # This class wraps the HTTP request object from Async::HTTP.
  # @example Basic request information
  #   request.method        #=> "GET"
  #   request.path_segments #=> ["api", "users", "123"]
  #   request.headers       #=> Protocol::HTTP::Headers instance
  #
  # @example Accessing request data
  #   request.params       #=> {"name" => "John", "email" => "john@example.com"}
  #   request.query_params #=> [["sort", "name"], ["order", "asc"]]
  #
  # @see https://github.com/socketry/async-http Async::HTTP documentation
  # @author Guilherme Silva
  # @since 1.0.0
  class Request
    # The HTTP method for this request.
    #
    # Common methods include GET, POST, PUT, DELETE, PATCH, HEAD, OPTIONS.
    # The method is automatically extracted from the underlying request object
    # and normalized to uppercase string format.
    #
    # @return [String] HTTP method in uppercase (e.g., "GET", "POST")
    # @example
    #   request.method #=> "GET"
    attr_reader :method

    # The path segments extracted from the request URL.
    #
    # The path is automatically split by "/" and empty segments are removed.
    # This creates an array that's perfect for pattern matching and routing logic.
    # Leading and trailing slashes are ignored.
    #
    # @return [Array<String>] Path segments without empty strings
    # @example Path segments
    #   # For URL: /api/users/123/profile
    #   request.path_segments #=> ["api", "users", "123", "profile"]
    #   user_id = request.path_segments[2]  #=> "123"
    #
    # @example Pattern Matching for Routing (Recommended)
    #   # Using Ruby's pattern matching for elegant routing
    #   case [request.method, request.path_segments]
    #   in ['GET', ['api', 'users', user_id]]
    #     # user_id automatically captured from URL
    #   in ['GET', ['api', 'posts', post_id, 'comments']]
    #     # post_id automatically captured from URL
    #   end
    attr_reader :path_segments

    # The original request object from the HTTP server.
    #
    # This provides access to the underlying request implementation when you need
    # low-level access to request data that isn't exposed through the wrapper methods.
    # Use this when you need to access protocol-specific features.
    #
    # @return [Object] The original request object from Async::HTTP
    # @see https://github.com/socketry/async-http/blob/main/lib/async/http/protocol/request.rb
    # @example
    #   request.raw_request.version #=> "HTTP/1.1"
    #   request.raw_request.scheme  #=> "http"
    attr_reader :raw_request

    # Initialize a new request wrapper.
    #
    # Creates a new Request instance that wraps the underlying HTTP request object.
    # Automatically extracts commonly needed information like HTTP method and path segments
    # for easy access and pattern matching.
    #
    # @param raw_request [Object] The original request object from Async::HTTP
    # @example
    #   # Usually called internally by the server
    #   request = Guaraci::Request.new(async_http_request)
    def initialize(raw_request)
      @method = raw_request.method
      @path_segments = raw_request.path&.split("/")&.reject(&:empty?)
      @raw_request = raw_request
    end

    # Read and return the request body content.
    # Returns nil if the request has no body content.
    #
    # @return [String, nil] The complete request body as a string
    # @example
    #   request.body #=> '{"name":"John","email":"john@example.com"}'
    # @example For requests without body
    #   request.body #=> nil
    def body
      @body ||= raw_request&.read
    end

    # Parse the request body as JSON and return the resulting object.
    #
    # Attempts to parse the request body as JSON using {JSON.parse}.
    # If the body is not valid JSON or is empty, returns an empty hash instead
    # of raising an exception. This makes it safe to call even when you're not
    # sure if the request contains JSON data.
    #
    # @return [Hash] Parsed JSON data, or empty hash if parsing fails
    # @see JSON.parse
    # @example Successful parsing
    #   # Request body: '{"name":"John","age":30}'
    #   request.params #=> {"name" => "John", "age" => 30}
    #
    # @example Invalid JSON handling
    #   # Request body: 'invalid json'
    #   request.params #=> {}
    #
    # @example Empty body handling
    #   # Request body: nil
    #   request.params #=> {}
    def params
      JSON.parse(body)
    rescue JSON::ParserError
      {}
    end

    # Access the request headers.
    #
    # @return [Protocol::HTTP::Headers] The request headers collection
    # @see https://github.com/socketry/protocol-http/blob/main/lib/protocol/http/headers.rb Protocol::HTTP::Headers
    # All headers are accessed in lowercase strings according to Protocol::HTTP::Headers
    # So that way, "User-Agent" becomes "user-agent"
    # @example
    #   request.headers['content-type']   #=> 'application/json'
    #   request.headers['authorization']  #=> 'Bearer token123'
    #   request.headers['user-agent']     #=> 'Mozilla/5.0...'
    def headers = raw_request.headers

    # Extract the query string from the request URL.
    #
    # Returns the complete query string portion of the URL (everything after the "?").
    # If no query string is present, returns an empty string. The query string is
    # returned as-is without any URL decoding.
    #
    # @return [String] The query string or empty string if none present
    # @example
    #   # For URL: /users?name=john&age=30&active=true
    #   request.query #=> "name=john&age=30&active=true"
    #
    # @example No query string
    #   # For URL: /users
    #   request.query #=> ""
    def query
      raw_request&.query || ""
    end

    # Parse the query string into key-value pairs.
    #
    # Splits the query string into an array of [key, value] pairs for easy processing.
    # Each parameter is split on the "=" character. Parameters without values will
    # have the value portion as an empty string or nil. The result is cached for
    # subsequent calls.
    #
    # @return [Array<Array<String>>] Array of [key, value] pairs
    # @example
    #   # For query: "name=john&age=30&active=true"
    #   request.query_params #=> [["name", "john"], ["age", "30"], ["active", "true"]]
    #
    # @example Parameters without values
    #   # For query: "debug&verbose=1&flag"
    #   request.query_params #=> [["debug"], ["verbose", "1"], ["flag"]]
    #
    # @example No query string
    #   request.query_params #=> []
    def query_params
      @query_params ||= parse_query
    end

    private

    # Split the query string into key-value pairs.
    #
    # Internal method that handles the actual parsing of the query string.
    # Splits on "&" to separate parameters, then splits each parameter on "="
    # to separate keys from values.
    #
    # @return [Array<Array<String>>] Parsed query parameters
    def parse_query
      query&.split("&")&.map { |q| q.split("=") }.to_a
    end
  end
end
