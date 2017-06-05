require 'devise/multi_email/version'
require 'devise'

module Devise
  module MultiEmail
    def self.configure(&block)
      yield self
    end

    @autosave_emails = false

    def self.autosave_emails
      @autosave_emails
    end

    def self.autosave_emails=(value)
      @autosave_emails = (value == true)
    end

    @only_login_with_primary_email = false

    def self.only_login_with_primary_email
      @only_login_with_primary_email
    end

    def self.only_login_with_primary_email=(value)
      @only_login_with_primary_email = (value == true)
    end

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

    def self.primary_email_method_name
      @primary_email_method_name ||= :primary_email_record
    end

    def self.primary_email_method_name=(name)
      @primary_email_method_name = name.try(:to_sym)
    end
  end
end

Devise.add_module :multi_email_authenticatable, model: 'devise/multi_email/models/authenticatable'
Devise.add_module :multi_email_confirmable, model: 'devise/multi_email/models/confirmable'
Devise.add_module :multi_email_validatable, model: 'devise/multi_email/models/validatable'
