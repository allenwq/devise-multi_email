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

        # Overrides Devise::Models::Recoverable#send_reset_password_instructions_notification
        # to send the reset password email to the address the user entered rather than always
        # defaulting to the primary email.
        def send_reset_password_instructions_notification(token)
          login_email = current_login_email.presence if respond_to?(:current_login_email)
          opts = login_email ? { to: login_email } : {}
          send_devise_notification(:reset_password_instructions, token, opts)
        end
      end
    end
  end
end
