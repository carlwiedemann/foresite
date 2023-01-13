# frozen_string_literal: true

require_relative "lib/foresite/version"

Gem::Specification.new do |spec|
  spec.name = "foresite"
  spec.version = Foresite::VERSION
  spec.authors = ["Carl Wiedemann"]
  spec.email = ["carl.wiedemann@gmail.com"]

  spec.summary = "A simple yet opinionated static site generator."
  spec.homepage = "https://github.com/carlwiedemann/foresite"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.7.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  spec.files = [
    'Gemfile',
    'LICENSE.txt',
    'README.md',
    'bin/foresite',
    'lib/foresite.rb',
    'lib/foresite/cli.rb',
    'lib/foresite/renderer.rb',
    'lib/foresite/version.rb',
    'lib/skeleton/sample_template.rhtml',
  ]

  spec.bindir = "bin"
  spec.executables = spec.files.grep(%r{\Abin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "zeitwerk", "~> 2.6"
  spec.add_dependency "thor", "~> 1.2"

  spec.add_development_dependency "rspec", "~> 3.2"
  spec.add_development_dependency "standard", "~> 1.3"
  spec.add_development_dependency "rake", "~> 13"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
