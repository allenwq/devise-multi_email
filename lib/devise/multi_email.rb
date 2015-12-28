require 'devise/multi_email/version'
require 'devise'

Devise.add_module :multi_email_authenticatable, model: 'devise/multi_email/models/authenticatable'
