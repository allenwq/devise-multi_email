require 'devise/multi_email/parent_model_extensions'

module Devise
  module Models
    module MultiEmailRecoverable
      extend ActiveSupport::Concern

      included do
        include Devise::MultiEmail::ParentModelExtensions

        devise :recoverable

        include RecoverableExtensions
      end

      def self.required_fields(klass)
        []
      end

      module RecoverableExtensions
        extend ActiveSupport::Concern

        # Generates a reset-password token and sends the notification.
        #
        # The +email+ keyword controls which address receives the reset email for
        # this specific call, overriding the global configuration:
        #
        # - +nil+ (default) — defers to +Devise::MultiEmail.password_reset_email_strategy+
        #                     (itself defaults to +:primary+).
        # - +:primary+      — always send to the user's primary email address.
        # - +:request+      — send to the email the user entered in the forgot-password
        #                     form (i.e. +current_login_email+).
        #
        # Examples:
        #   user.send_reset_password_instructions                    # global default (:primary)
        #   user.send_reset_password_instructions(email: :primary)
        #   user.send_reset_password_instructions(email: :request)
        def send_reset_password_instructions(email: nil)
          token = set_reset_password_token
          send_reset_password_instructions_notification(token, email: email)
          token
        end

        protected

        # Overrides Devise::Models::Recoverable#send_reset_password_instructions_notification.
        # Callers should prefer the public #send_reset_password_instructions(email:) method
        # rather than calling this directly.
        def send_reset_password_instructions_notification(token, email: nil)
          strategy = email || Devise::MultiEmail.password_reset_email_strategy

          opts =
            if strategy == :request && respond_to?(:current_login_email)
              login_email = current_login_email.presence
              login_email ? { to: login_email } : {}
            else
              {}
            end

          send_devise_notification(:reset_password_instructions, token, opts)
        end
      end
    end
  end
end
