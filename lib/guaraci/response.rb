# frozen_string_literal: true

require "json"

module Guaraci
  # This class is responsible for build the response for the framework,
  #  that need to return an array with status, header and body
  #  like that ~> [200, {"Content-Type": "application/json"}, "{"message": "cool"}"]
  class Response
    attr_reader :status, :body, :headers

    def initialize(status)
      @status = status
      @headers = {}
      @body = []
    end

    def self.ok
      res = new(200)
      yield(res) if block_given?
      res
    end

    def json(object)
      @headers["Content-Type"] = "application/json"
      @body = [JSON.dump(object)]
    end

    def to_a
      [@status, @headers, @body]
    end
  end
end
