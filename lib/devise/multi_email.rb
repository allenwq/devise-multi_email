require 'devise/multi_email/version'
require 'devise'

module Devise
  module MultiEmail
    def self.parent_association_name
      @parent_association_name ||= :user
    end

    def self.parent_association_name=(name)
      @parent_association_name = name.try(:to_sym)
    end

    def self.emails_association_name
      @emails_association_name ||= :emails
    end

    def self.emails_association_name=(name)
      @emails_association_name = name.try(:to_sym)
    end
  end
end

Devise.add_module :multi_email_authenticatable, model: 'devise/multi_email/models/authenticatable'
Devise.add_module :multi_email_confirmable, model: 'devise/multi_email/models/confirmable'
Devise.add_module :multi_email_validatable, model: 'devise/multi_email/models/validatable'
