# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'devise/multi_email/version'

Gem::Specification.new do |spec|
  spec.name          = 'devise-multi_email'
  spec.version       = Devise::MultiEmail::VERSION
  spec.authors       = ["ALLEN WANG QIANG"]
  spec.email         = ["rovingbreeze@gmail.com"]

  spec.summary       = %q{Devise with multiple emails.}
  spec.description   = %q{Devise authenticatable and confirmable with multiple emails.}
  spec.homepage      = 'https://github.com/allenwq/devise-multi_email.git'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.10'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec'

  spec.add_runtime_dependency 'devise'
end
