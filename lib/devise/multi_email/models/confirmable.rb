require 'devise/multi_email/parent_model_extensions'

module Devise
  module Models
    module EmailConfirmable
      extend ActiveSupport::Concern

      included do
        devise :confirmable

        include ConfirmableExtensions
      end

      module ConfirmableExtensions
        def confirmation_period_valid?
          primary? ? super : false
        end
      end
    end

    module MultiEmailConfirmable
      extend ActiveSupport::Concern

      included do
        include Devise::MultiEmail::ParentModelExtensions

        devise :confirmable

        include ConfirmableExtensions
      end

      def self.required_fields(klass)
        []
      end

      module ConfirmableExtensions
        extend ActiveSupport::Concern

        included do
          multi_email_association.include_module(EmailConfirmable)
        end

        # delegate before creating overriding methods
        delegate :skip_confirmation!, :skip_confirmation_notification!, :skip_reconfirmation!, :confirmation_required?,
                 :confirmation_token, :confirmed_at, :confirmation_sent_at, :confirm, :confirmed?, :unconfirmed_email,
                 :reconfirmation_required?, :pending_reconfirmation?, to: :primary_email_record, allow_nil: true

        # In case email updates are being postponed, don't change anything
        # when the postpone feature tries to switch things back
        def email=(new_email)
          multi_email.change_primary_email_to(new_email, force_primary: false)
        end

        # This need to be forwarded to the email that the user logged in with
        def active_for_authentication?
          login_email = multi_email.login_email_record

          if login_email && !login_email.primary?
            super && login_email.active_for_authentication?
          else
            super
          end
        end

        # Shows email not confirmed instead of account inactive when the email that user used to login is not confirmed
        def inactive_message
          login_email = multi_email.login_email_record

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

        module ClassMethods
          delegate :confirm_by_token, :send_confirmation_instructions, to: 'multi_email_association.model_class', allow_nil: false
        end
      end
    end
  end
end
