require 'devise/multi_email/version'
require 'devise'

module Devise
  module MultiEmail
    # Default: send password reset to the address the user entered, not always the primary.
    @send_reset_password_to_login_email = true

    class << self
      def configure
        yield self
      end

      @autosave_emails = false

      def autosave_emails?
        @autosave_emails == true
      end

      def autosave_emails=(value)
        @autosave_emails = (value == true)
      end

      @only_login_with_primary_email = false

      def only_login_with_primary_email?
        @only_login_with_primary_email == true
      end

      def only_login_with_primary_email=(value)
        @only_login_with_primary_email = (value == true)
      end

      # When true (default), password reset emails are sent to the address the
      # user typed into the forgot-password form rather than the primary email.
      # Set to false to always send password reset emails to the primary email.

      def send_reset_password_to_login_email?
        @send_reset_password_to_login_email == true
      end

      def send_reset_password_to_login_email=(value)
        @send_reset_password_to_login_email = (value == true)
      end

      def parent_association_name
        @parent_association_name ||= :user
      end

      def parent_association_name=(name)
        @parent_association_name = name.try(:to_sym) unless '' == name
      end

      def emails_association_name
        @emails_association_name ||= :emails
      end

      def emails_association_name=(name)
        @emails_association_name = name.try(:to_sym) unless '' == name
      end

      def primary_email_method_name
        @primary_email_method_name ||= :primary_email_record
      end

      def primary_email_method_name=(name)
        @primary_email_method_name = name.try(:to_sym) unless '' == name
      end
    end
  end
end

Devise.add_module :multi_email_authenticatable, model: 'devise/multi_email/models/authenticatable'
Devise.add_module :multi_email_confirmable, model: 'devise/multi_email/models/confirmable'
Devise.add_module :multi_email_recoverable, model: 'devise/multi_email/models/recoverable'
Devise.add_module :multi_email_validatable, model: 'devise/multi_email/models/validatable'
