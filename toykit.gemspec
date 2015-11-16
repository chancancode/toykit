# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'toykit/version'

Gem::Specification.new do |spec|
  spec.name          = "toykit"
  spec.version       = ToyKit::VERSION
  spec.authors       = ["Godfrey Chan"]
  spec.email         = ["godfreykfc@gmail.com"]

  spec.summary       = "A toolkit for implementing toy languages"
  spec.description   = "A toolkit for implementing toy languages for learning and educational purposes."
  spec.homepage      = "https://github.com/chancancode/toykit"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^test/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest"
end
