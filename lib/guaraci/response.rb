# frozen_string_literal: true

require 'json'

module Guaraci
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
      @body = [JSON.dump((object))]
    end

    def to_a
      [@status, @headers, @body]
    end
  end
end