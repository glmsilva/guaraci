# frozen_string_literal: true

require_relative "test_helper"

class TestGuaraci < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil Guaraci::VERSION
  end

  def test_that_it_can_create_a_server
    @server = Guaraci::Server.new do |_req|
      Guaraci::Response.ok
    end

    assert_instance_of Guaraci::Server, @server
  end

  def test_that_response_class_exists
    @response = Guaraci::Response.ok
    assert_instance_of Guaraci::Response, @response
    assert_equal 200, @response.status
  end

  def test_that_all_classes_are_available
    assert defined?(Guaraci::Server)
    assert defined?(Guaraci::Request)
    assert defined?(Guaraci::Response)
  end
end
