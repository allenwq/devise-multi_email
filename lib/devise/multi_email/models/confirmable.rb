module Devise
  module Models
    module EmailConfirmable
      extend ActiveSupport::Concern

      included do
        devise :confirmable

        extend ClassReplacementMethods
      end

      module ClassReplacementMethods
        def allow_unconfirmed_access_for
          0.day
        end
      end
    end

    module MultiEmailConfirmable
      extend ActiveSupport::Concern

      included do
        devise :confirmable
        include InstanceReplacementMethods
        extend ClassReplacementMethods

        email_class.send :include, EmailConfirmable
      end

      def self.required_fields(klass)
        []
      end

      module InstanceReplacementMethods
        delegate :skip_confirmation!, :skip_confirmation_notification!, :skip_reconfirmation!, :confirmation_required?,
                 :confirmation_token, :confirmed_at, :confirmation_sent_at, :confirm, :confirmed?, :unconfirmed_email,
                 :reconfirmation_required?, :pending_reconfirmation?, to: :primary_email_record, allow_nil: true

        # This need to be forwarded to the email that the user logged in with
        def active_for_authentication?
          login_email = current_login_email_record

          if login_email && !login_email.primary?
            super && login_email.active_for_authentication?
          else
            super
          end
        end

        # Shows email not confirmed instead of account inactive when the email that user used to login is not confirmed
        def inactive_message
          login_email = current_login_email_record

          if login_email && !login_email.primary? && !login_email.confirmed?
            :unconfirmed
          else
            super
          end
        end

        protected

        # Overrides Devise::Models::Confirmable#postpone_email_change?
        def postpone_email_change?
          false
        end

        # Email should handle the confirmation token.
        def generate_confirmation_token
        end

        # Email will send reconfirmation instructions.
        def send_reconfirmation_instructions
        end

        # Email will send confirmation instructions.
        def send_on_create_confirmation_instructions
        end

        private

        def current_login_email_record
          if respond_to?(:current_login_email) && current_login_email
            __send__(Devise::MultiEmail.emails_association_name).find_by(email: current_login_email)
          end
        end
      end

      module ClassReplacementMethods
        # Overrides Devise::Models::Confirmable.confirm_by_token
        # Forward the logic to email.
        def confirm_by_token(token)
          email_class.confirm_by_token(token)
        end

        # Overrides Devise::Models::Confirmable.send_confirmation_instructions
        # Forward the logic to email.
        def send_confirmation_instructions(params)
          email_class.send_confirmation_instructions(params)
        end
      end
    end
  end
end
