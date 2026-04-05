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

        protected

        # Overrides Devise::Models::Recoverable#send_reset_password_instructions_notification.
        #
        # The +email+ keyword controls which address receives the password reset notification:
        #
        # - +nil+ (default) — defers to the global +Devise::MultiEmail.password_reset_email_strategy+
        #                     setting, which defaults to +:primary+.
        # - +:primary+      — always send to the user's primary email address.
        # - +:request+      — send to the email address the user entered in the
        #                     forgot-password form (i.e. +current_login_email+).
        #
        # Examples:
        #   user.send_reset_password_instructions_notification(token)             # global default
        #   user.send_reset_password_instructions_notification(token, email: :primary)
        #   user.send_reset_password_instructions_notification(token, email: :request)
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
