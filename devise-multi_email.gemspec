lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'devise/multi-email/version'

Gem::Specification.new do |spec|
  spec.name          = 'devise-multi-email'
  spec.version       = Devise::MultiEmail::VERSION
  spec.authors       = ['ALLEN WANG QIANG', 'Joel Van Horn', 'Micah Gideon Modell']
  spec.email         = ['rovingbreeze@gmail.com', 'joel@joelvanhorn.com', 'micah.modell@gmail.com']

  spec.summary       = 'Let devise support multiple emails.'
  spec.description   = 'Devise authenticatable, confirmable and validatable with multiple emails.'
  spec.homepage      = 'https://github.com/allenwq/devise-multi_email.git'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 3.0', '<5.0'

  spec.add_runtime_dependency 'devise', '<6.0'

  spec.add_development_dependency 'bundler', '<5.0'
  spec.add_development_dependency 'capybara', '<4.0'
  spec.add_development_dependency 'coveralls', '<=0.8.23'
  spec.add_development_dependency 'rake', '<14.0'
  spec.add_development_dependency 'rspec', '<4.0'
  spec.add_development_dependency 'sqlite3', '<=2.9.0'
end
