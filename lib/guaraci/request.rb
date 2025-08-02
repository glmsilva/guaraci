# frozen_string_literal: true

require "json"

module Guaraci
  # This class is responsible for build the request object and its methods. Just like that :)
  class Request
    attr_reader :method, :path_segments, :raw_request

    def initialize(raw_request)
      @method = raw_request.method
      @path_segments = raw_request.path&.split("/")&.reject(&:empty?)
      @raw_request = raw_request
    end

    def body
      @body ||= raw_request&.read
    end

    def params
      JSON.parse(body)
    rescue JSON::ParserError
      {}
    end

    def headers = raw_request.headers

    def query
      raw_request&.query || ""
    end

    def query_params
      @query_params ||= parse_query
    end

    private

    def parse_query
      query&.split("&")&.map { |q| q.split("=") }.to_a
    end
  end
end
