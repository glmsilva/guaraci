# frozen_string_literal: true

require_relative "../test_helper"

module Guaraci
  class TestServerCall < Minitest::Test
    def setup
      @server = Guaraci::Server.new do |request|
        response = Guaraci::Response.ok
        response.json({ message: "test" })
        response
      end

      @mock_request = Minitest::Mock.new
      
      @mock_request.expect(:read, "")
      @mock_request.expect(:method, "GET")
      @mock_request.expect(:path, "/mock/api")
      @mock_request.expect(:query, "size=small&id=11")
      @mock_request.expect(:headers, {})
    end

    def test_call_returns_response_object
      result = @server.call(@mock_request)
      
      assert_kind_of Guaraci::Response, result
      assert_equal 200, result.status
      assert_kind_of Protocol::HTTP::Headers, result.headers
      assert_equal "application/json", result.headers["content-type"]
      assert_kind_of Protocol::HTTP::Body::Buffered, result.body
    end
  end
end
