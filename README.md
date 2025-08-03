# ☀️ Guaraci

[![Static Badge](https://img.shields.io/badge/rubygems-guaraci-brightgreen)](https://rubygems.org/gems/guaraci)
[![Gem Version](https://badge.fury.io/rb/guaraci.svg?icon=si%3Arubygems)](https://badge.fury.io/rb/guaraci)

[![Ruby](https://img.shields.io/badge/ruby-%3E%3D%203.4.0-red.svg)](https://ruby-lang.org)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Guaraci is very a simple Ruby web microframework built on top of the powerful [Async::HTTP](https://github.com/socketry/async-http).
It was designed to be minimalist, providing a clean and intuitive API with as little overhead as possible.

Its goal is to be minimalist, with a small codebase focused on simplicity, without the need to learn extensive DSLs like other frameworks; it only requires plain Ruby.

## Features

- **High performance** - Powered by Async::HTTP for non-blocking concurrency
- **Flexible** - Easy to extend and customize
- **Lightweight** - Few dependencies

## Installation

In your gemfiile:

```ruby
gem 'guaraci'
```

And run:

```bash
bundle install
```

Or:

```bash
gem install guaraci
```

## How to use

### Hello World

```ruby
require 'guaraci'

Guaraci::Server.run(port: 3000) do |request|
  response = Guaraci::Response.ok
  response.json({ message: "Hello, World!" })
  response.render
end
```

### Routing
A little about routing first: I decided to keep the code simple, so no routing dsl and constructors were built. Why? The ideia is to use plain ruby, without the need to learn another DSL apart ruby itself, like rails, sinatra, roda, etc.

I REALLY recommend you to use the new pattern matching feature that comes with Ruby 3.x by default.

```ruby
require 'guaraci'

Guaraci::Server.run(host: 'localhost', port: 8000) do |request|
  case [request.method, request.path_segments]
  in ['GET', []]
    handle_api_request(request)
  in ['GET', ['health']]
    health_check
  else
    not_found
  end
end

def handle_api_request(request)
  response = Guaraci::Response.ok
  response.json({
    method: request.method,
    path: request.path_segments,
    params: request.params,
    timestamp: Time.now.iso8601
  })
  response.render

##  Or you can pass a block like this
#
#   Guaraci::Response.ok do |res|
#     res.json({
#       method: request.method,
#       path: request.path_segments,
#       params: request.params,
#       timestamp: Time.now.iso8601
#      })
#   end.to_a
end

def health_check
  response = Guaraci::Response.ok
  response.json({ status: 'healthy', uptime: Process.clock_gettime(Process::CLOCK_MONOTONIC) })
  response.render

## Or you can pass a block like this
#
#   Guaraci::Response.ok do |res|
#     res.json({
#       status: 'healthy',
#       uptime: Process.clock_gettime(Process::CLOCK_MONOTONIC)
#     })
#   end
end

def not_found
  response = Guaraci::Response.new(404)
  response.json({ error: 'Not Found' })
  response.render
end

```

## Examples

You can see more examples on how to build guaraci apps inside [Examples](https://github.com/glmsilva/guaraci/tree/main/examples) folder

## Development

Clone the repository:

1. Execute `bin/setup` to install dependencies
2. Execute `rake test` to run tests
3. Execute `bin/console` for an interactive prompt

### Tests
Its the plain and old minitest :)

```bash
rake test

ruby test/guaraci/test_request.rb

bundle exec rubocop
```

## Inspiration
### Why this name?

In **Tupi-Guarani** indigenous culture, Guaraci (_Guaracy_ or _Kûarasy_) is the solar deity associated with the origin of life. As a central figure in indigenous mythology, and son of **Tupã**, Guaraci embodies the power of the sun, is credited with giving rise to all living beings, and protector of the hunters.

Its also a word that can be translated to "Sun" in Tupi-Guarani language.

## Roadmap

- [ ] Integrated pipeline Middleware
- [ ] Templates support
- [ ] WebSocket support
- [ ] Streaming responses
- [ ] A better documentation
- [ ] More examples on how to use it
- [ ] Performance benchmark

## Acknowledgements

- [Async::HTTP](https://github.com/socketry/async-http) - The powerful asynchronous base of this project
- [Wisp](https://github.com/gleam-wisp/wisp) - The great framework that I enjoyed using so much and that inspired the philosophy behind building this one

## 📄 License
 [MIT License](https://opensource.org/licenses/MIT).

---

Thank you so much, feel free to contact me ☀️ [Guilherme Silva](https://github.com/glmsilva)
