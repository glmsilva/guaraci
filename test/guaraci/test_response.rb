# frozen_string_literal: true

require_relative "../test_helper"

module Guaraci
  class TestResponse < Minitest::Test
    def test_that_status_is_created
      @response = Response.ok

      assert_equal @response.status, 200
    end

    def test_that_body_is_created
      @response = Response.ok
      @response.json({ message: "Hello, world!" }).to_json

      assert @response.body.read.is_a? String
    end

    def test_that_header_is_created
      @response = Response.ok { |res| res.html("<h1>Hello, world!</h1>") }

      assert @response.headers.is_a? Object
      assert_equal @response.headers["content-type"], "text/html"
    end

    def test_that_render_return_a_valid_async_http_response
      @response = Response.ok { |res| res.json({ message: "Hello, world!" }) }

      assert_instance_of Protocol::HTTP::Response, @response.render
    end
  end
end
