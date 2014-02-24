# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'streamingly/version'

Gem::Specification.new do |spec|
  spec.name          = "streamingly"
  spec.version       = Streamingly::VERSION
  spec.authors       = ["Matt Gillooly"]
  spec.email         = ["matt@swipely.com"]
  spec.description   = %q{Helpful classes for writing streaming Hadoop jobs in Ruby}
  spec.summary       = %q{Helpful classes for writing streaming Hadoop jobs in Ruby}
  spec.homepage      = "http://github.com/swipely/streamingly"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 2.11"
end
