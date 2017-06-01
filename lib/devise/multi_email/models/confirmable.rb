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

          before_update do
            # Handle automatically confirming and linking `unconfirmed_email`
            # when email change is not postponed (which basically means
            # Devise is not configured to require confirmation)
            if !postponed_email_change? && multi_email.unconfirmed_email_changes?
              multi_email.set_primary_record_to(
                multi_email.unconfirmed_email_record,
                skip_confirmations: true
              )
            end
          end

          # When changing the email address on the parent record, the default Devise
          # lifecycle will take care of sending a confirmation email. This callback
          # prevents sending the notification emails again for each Email record.
          # *NOTE* This does not confirm the emails, it simply skips sending a
          # confirmation email.
          if respond_to?(:after_commit)
            after_commit(prepend: true){ multi_email.primary_email_record.try(:skip_confirmation_notification!) }
          else # Mongoid
            after_create(prepend: true){ multi_email.primary_email_record.try(:skip_confirmation_notification!) }
            after_update(prepend: true){ multi_email.primary_email_record.try(:skip_confirmation_notification!) }
          end

          alias_method :email_in_database, :email
          alias_method :email_was, :email
        end

        delegate :confirmation_token, :confirmation_token=,
                 :confirmed_at, :confirmed_at=, :confirmation_sent_at, :confirmation_sent_at=,
                 to: 'multi_email.current_email_record', allow_nil: true

        delegate :email_changed?, :will_save_change_to_email?, to: 'multi_email.unconfirmed_email_record', allow_nil: true

        # Override to reset flag indicating if email change was postponed.
        # (Used in `before_commit` hook to handle confirming `unconfirmed_email`)
        # See `multi_email#before_commit_confirm_unconfirmed_email_when_not_postponed`
        def postpone_email_change?
          # Reset the flag that indicates whether the email change was postponed
          @postponed_email_change = super
        end

        # Indicates if the email change was postponed in the `before_commit` callback.
        # See `multi_email#before_commit_confirm_unconfirmed_email_when_not_postponed`
        def postponed_email_change?
          @postponed_email_change == true
        end

        # Override to confirm unconfirmed emails properly
        def confirm(args={})
          pending_any_confirmation do
            if pending_reconfirmation?
              # mark as confirmed so it's automatically set to primary email by Devise below
              multi_email.unconfirmed_email_record.skip_confirmation!

              transaction(requires_new: true) do
                # Devise sets `email = unconfirmed_email` and then `unconfirmed_email = nil`
                saved = super

                if saved && self.class.multi_email_association.autosave_changes? && multi_email.unconfirmed_email_record.changes?
                  multi_email.unconfirmed_email_record.save!
                end
              end
            else
              saved = multi_email.current_email_record.confirm(args)
            end

            saved
          end
        end

        # In case email updates are being postponed, don't change anything
        # when the postpone feature tries to switch things back
        def email=(new_email)
          multi_email.change_primary_email_to(new_email, make_primary: false)
        end

        def unconfirmed_email=(new_email)
          # `new_email` is set to nil by Devise when `confirm` is called
          # and we don't need to do anything here
          self.email = new_email unless new_email.blank?
        end

        def unconfirmed_email
          multi_email.unconfirmed_email_record.try(:email)
        end

      private

        module ClassMethods
          delegate :confirm_by_token, to: 'multi_email_association.model_class', allow_nil: false
        end
      end
    end
  end
end
