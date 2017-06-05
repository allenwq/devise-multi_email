require File.expand_path('../boot', __FILE__)

require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'active_record/railtie'
require 'rails/test_unit/railtie'

require 'devise/multi_email'

module RailsApp
  class Application < Rails::Application
    # Add additional load paths for your own custom dirs
    config.autoload_paths.reject! { |p| p =~ /\/app\/(\w+)$/ && !%w(controllers helpers mailers models views).include?($1) }

    # Configure generators values. Many other options are available, be sure to check the documentation.
    # config.generators do |g|
    #   g.orm             :active_record
    #   g.template_engine :erb
    #   g.test_framework  :test_unit, fixture: true
    # end

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters << :password
    # config.assets.enabled = false

    config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }

    # This was used to break devise in some situations
    config.to_prepare do
      Devise::SessionsController.layout 'application'
    end
  end
end
