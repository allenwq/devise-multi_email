module Devise
  module Models
    module EmailConfirmable
      extend ActiveSupport::Concern
      USER_ASSOCIATION = :user

      included do
        devise :confirmable
      end

      def devise_scope
        user_association = self.class.reflect_on_association(USER_ASSOCIATION)
        if user_association
          user_association.class_name.constantize
        else
          raise "#{self.class.name}: Association :#{USER_ASSOCIATION} not found: Have you declared that ?"
        end
      end
    end

    module MultiEmailConfirmable
      extend ActiveSupport::Concern
      EMAILS_ASSOCIATION = :emails

      included do
        devise :confirmable
        include InstanceReplacementMethods
        extend ClassReplacementMethods

        email_class.send :include, EmailConfirmable
      end

      module InstanceReplacementMethods
        delegate :skip_confirmation!, :skip_confirmation_notification!, :skip_reconfirmation!, :confirmation_required?,
                 :confirmed?, :confirmation_period_valid?, :reconfirmation_required?, to: :primary_email_record

        def unconfirmed_email
          primary_email_record.try(:unconfirmed_email)
        end

        def pending_reconfirmation?
          primary_email = primary_email_record
          primary_email && primary_email.pending_reconfirmation?
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
      end

      module ClassReplacementMethods
        def email_class
          email_association = reflect_on_association(EMAILS_ASSOCIATION)
          if email_association
            email_association.class_name.constantize
          else
            raise "#{self.class.name}: Association :#{EMAILS_ASSOCIATION} not found: It might because your declaration is after `devise :multi_email_confirmable`."
          end
        end

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