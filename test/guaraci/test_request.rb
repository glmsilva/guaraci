# frozen_string_literal: true

require_relative "../test_helper"

module Guaraci
  class TestRequest < Minitest::Test
    def setup
      @params = { message: "Hello, Guaraci!" }
      @request_mock = Minitest::Mock.new

      @request_mock.expect(:read, @params.to_json)
      @request_mock.expect(:method, "get")
      @request_mock.expect(:path, "/mock/api")
      @request_mock.expect(:query, "size=small&id=11")

      @object = Guaraci::Request.new(@request_mock)
    end

    def test_that_body_is_read
      assert_equal @params.to_json, @object.body
    end

    def test_that_params_is_parsed
      assert @object.params.is_a?(Hash)
      assert_equal "Hello, Guaraci!", @object.params["message"]
    end

    def test_that_query_is_parsed
      assert @object.query_params.is_a?(Array)
      assert_equal [%w[size small], %w[id 11]], @object.query_params
    end

    def test_parse_params_with_error
      empty_mock = Minitest::Mock.new
      empty_mock.expect(:read, "")
      empty_mock.expect(:method, "get")
      empty_mock.expect(:path, "/mock/api")
      empty_mock.expect(:query, "")

      object = Guaraci::Request.new(empty_mock)

      assert object.params.empty?
    end
  end
end
