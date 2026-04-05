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

        # Per-instance override for the global send_reset_password_to_login_email
        # configuration. Set to +true+ or +false+ to override the global setting
        # for this object only. Set to +nil+ to revert to the global default.
        #
        #   user.send_reset_password_to_login_email = false
        #   user.send_reset_password_instructions
        attr_writer :send_reset_password_to_login_email

        protected

        # Overrides Devise::Models::Recoverable#send_reset_password_instructions_notification
        # to send the reset password email to the address the user entered rather than always
        # defaulting to the primary email.
        #
        # The destination address is controlled by:
        #   1. The per-instance @send_reset_password_to_login_email attribute (if set).
        #   2. The global Devise::MultiEmail.send_reset_password_to_login_email? setting.
        #
        # When the effective setting is +true+ (the default), the notification is
        # sent to the email address from the sign-in/forgot-password request.
        # When +false+, it is sent to the user's primary email address.
        def send_reset_password_instructions_notification(token)
          use_login_email =
            if instance_variable_defined?(:@send_reset_password_to_login_email) &&
               !@send_reset_password_to_login_email.nil?
              @send_reset_password_to_login_email
            else
              Devise::MultiEmail.send_reset_password_to_login_email?
            end

          opts =
            if use_login_email && respond_to?(:current_login_email)
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
