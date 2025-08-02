require_relative "../test_helper"

class Guaraci::TestRequest < Minitest::Test
  RequestMock = Struct.new(:method, :path, :read, :query)

  def setup
    @params = { message: "Hello, Guaraci!" }
    @request_mock = RequestMock.new(method: "get", path: "mock/routing", query: "size=small&id=11", read: @params.to_json)
    @object = Guaraci::Request.new(@request_mock)
  end

  def test_that_body_is_read
    assert_equal @request_mock.read, @object.body
  end

  def test_that_params_is_parsed
    assert @object.params.is_a? Hash
    assert_equal "Hello, Guaraci!", @object.params["message"]
  end

  def test_that_query_is_parsed
    assert @object.query_params.is_a? Array
    assert_equal [["size", "small"], ["id", "11"]], @object.query_params
  end

  def test_parse_params_with_error
    @request_mock = RequestMock.new(read: "")
    @object = Guaraci::Request.new(@request_mock)

    assert @object.params.empty?
  end
end
