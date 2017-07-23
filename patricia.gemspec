# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'patricia/version'

Gem::Specification.new do |spec|
  spec.name          = "patricia"
  spec.version       = Patricia::VERSION
  spec.authors       = ["<username>"]
  spec.email         = [""]
  spec.summary       = "Minimal markup-based Wiki"
  spec.description   = "Renders markup Wiki pages in the browser or \
generates static files. Hierarchical tree navigation for all pages is \
provided."
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
end
