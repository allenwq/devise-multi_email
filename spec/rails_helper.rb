ENV['RAILS_ENV'] = 'test'

require 'spec_helper'
require 'capybara/rspec'
require 'rails_app/config/environment'
require 'orm/active_record'

Capybara.app = RailsApp::Application

RSpec.configure do |config|
  config.include RailsApp::Application.routes.url_helpers
end

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }
