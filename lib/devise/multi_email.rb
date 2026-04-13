require 'devise/multi_email/version'
require 'devise'

module Devise
  module MultiEmail
    # Default strategy for password reset emails: :primary or :request.
    # :primary (default) sends to the user's primary email address.
    # :request sends to the email address used in the forgot-password form.
    @password_reset_email_strategy = :primary

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

      # Controls which address receives password reset emails by default.
      # Accepts :primary (default) or :request.
      # :primary — always send to the user's primary email.
      # :request — send to the email address the user entered in the forgot-password form.
      # This default can be overridden per call via the email: keyword on
      # send_reset_password_instructions_notification.

      def password_reset_email_strategy
        @password_reset_email_strategy
      end

      def password_reset_email_strategy=(value)
        value = value.try(:to_sym)
        if value == :request
          @password_reset_email_strategy = :request
        else
          @password_reset_email_strategy = :primary
        end
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

# Register multi_email modules right after their standard Devise counterparts in Devise::ALL.
# This ensures they are always processed before third-party extensions such as
# devise-encryptable, regardless of gem load order in the Gemfile. The sort in
# Devise::Models#devise uses Devise::ALL ordering when including modules, so a lower
# index here guarantees the base module (e.g. database_authenticatable) is included
# before any override module (e.g. encryptable), preserving the correct MRO.
Devise.add_module :multi_email_authenticatable,
                  model: 'devise/multi_email/models/authenticatable',
                  insert_at: Devise::ALL.index(:database_authenticatable).to_i + 1
Devise.add_module :multi_email_confirmable,
                  model: 'devise/multi_email/models/confirmable',
                  insert_at: Devise::ALL.index(:confirmable).to_i + 1
Devise.add_module :multi_email_recoverable,
                  model: 'devise/multi_email/models/recoverable',
                  insert_at: Devise::ALL.index(:recoverable).to_i + 1
Devise.add_module :multi_email_validatable,
                  model: 'devise/multi_email/models/validatable',
                  insert_at: Devise::ALL.index(:validatable).to_i + 1
