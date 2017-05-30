# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'devise/multi_email/version'

Gem::Specification.new do |spec|
  spec.name          = 'devise-multi_email'
  spec.version       = Devise::MultiEmail::VERSION
  spec.authors       = ['ALLEN WANG QIANG', 'Joel Van Horn']
  spec.email         = ['rovingbreeze@gmail.com', 'joel@joelvanhorn.com']

  spec.summary       = %q{Let devise support multiple emails.}
  spec.description   = %q{Devise authenticatable, confirmable and validatable with multiple emails.}
  spec.homepage      = 'https://github.com/allenwq/devise-multi_email.git'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'devise'

  spec.add_development_dependency 'bundler', '~> 1.10'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'sqlite3'
  spec.add_development_dependency 'capybara'
  spec.add_development_dependency 'coveralls'
end
