$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

ENV['RAILS_ENV'] = 'test'

require 'capybara/rspec'

require 'devise/multi_email'
require 'rails_app/config/environment'
require 'rails/test_help'
require 'orm/active_record'

Capybara.app = RailsApp::Application
Capybara.save_and_open_page_path = File.expand_path('../../tmp', __FILE__)

RSpec.configure do |config|
  config.include RailsApp::Application.routes.url_helpers
end

# Add support to load paths so we can overwrite broken webrat setup
$:.unshift File.expand_path('../support', __FILE__)
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }