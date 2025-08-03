# frozen_string_literal: true

require_relative "./guaraci/server"
require_relative "./guaraci/response"
require_relative "./guaraci/request"
require_relative "./guaraci/version"

# # Guaraci is a minimalist Ruby web framework built on Async::HTTP.
# It provides a simple, clean API for building web applications without
# complex DSLs or extensive configuration.
#
# The framework embraces plain Ruby patterns and encourages the use of
# pattern matching for routing, making it perfect for modern Ruby applications.
#
# @example Basic application
#   require 'guaraci'
#
#   Guaraci::Server.run do |request|
#     case [request.method, request.path_segments]
#     in ['GET', []]
#       Guaraci::Response.ok { |r| r.html("<h1>Welcome to Guaraci!</h1>") }.render
#     in ['GET', ['api', 'health']]
#       Guaraci::Response.ok { |r| r.json({status: "ok", timestamp: Time.now}) }.render
#     else
#       Guaraci::Response.new(404) { |r| r.json({error: "Not found"}) }.render
#     end
#   end
#
# @author Guilherme Silva
# @version 1.0.0
module Guaraci
end
