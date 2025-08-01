# frozen_string_literal: true

require_relative "lib/guaraci/version"

Gem::Specification.new do |spec|
  spec.name = "guaraci"
  spec.version = Guaraci::VERSION
  spec.authors = ["Guilherme Silva"]
  spec.email = ["guilherme.gss@outlook.com.br"]

  spec.summary = "Guaraci ruby web microframework"
  spec.description = "A very simple web framework made with async http"
  spec.homepage = "https://github.com/glmsilva/guaraci"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["source_code_uri"] = "https://github.com/glmsilva/guaraci"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ Gemfile .gitignore test/ .github/ .rubocop.yml])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "async", "~> 2.27.0"
  spec.add_dependency "async-http", "~> 0.89.0"
  spec.add_dependency "json"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
