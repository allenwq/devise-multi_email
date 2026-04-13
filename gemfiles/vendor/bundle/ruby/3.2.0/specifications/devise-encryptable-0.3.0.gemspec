# -*- encoding: utf-8 -*-
# stub: devise-encryptable 0.3.0 ruby lib

Gem::Specification.new do |s|
  s.name = "devise-encryptable".freeze
  s.version = "0.3.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Carlos Antonio da Silva".freeze, "Jos\u00E9 Valim".freeze, "Rodrigo Flores".freeze]
  s.date = "1980-01-02"
  s.description = "Encryption solution for salted-encryptors on Devise".freeze
  s.email = "heartcombo.oss@gmail.com".freeze
  s.homepage = "https://github.com/heartcombo/devise-encryptable".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.4.20".freeze
  s.summary = "Encryption solution for salted-encryptors on Devise".freeze

  s.installed_by_version = "3.4.20" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<devise>.freeze, [">= 2.1.0"])
  s.add_development_dependency(%q<minitest>.freeze, ["< 6"])
  s.add_development_dependency(%q<mocha>.freeze, [">= 0"])
  s.add_development_dependency(%q<rake>.freeze, [">= 0"])
end
