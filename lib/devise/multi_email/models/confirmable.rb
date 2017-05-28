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

        # Indicates if the `email` and `unconfirmed_email` are being updated
        # during the postpone-email-change `before_commit` callback
        # See `postpone_email_change_until_confirmation_and_regenerate_confirmation_token`
        def currently_postponing_email_change?
          @currently_postponing_email_change == true
        end

        # Override to set flags that indicate postpone-email-change is currently happening.
        # See `multi_email#change_primary_email_to`
        def postpone_email_change_until_confirmation_and_regenerate_confirmation_token
          @currently_postponing_email_change = true
          super
        ensure
          @currently_postponing_email_change = false
        end

        # Override to set flags that indicate confirmation is currently happening.
        # See `multi_email#switching_to_unconfirmed_email?`
        def confirm(*)
          @currently_confirming = true
          super
        ensure
          @currently_confirming = false
        end

        # Indicates if `confirm` is currently being called on the parent model
        # and the `email` and `unconfirmed_email` changes should be handled specially.
        # See `email=`
        def currently_confirming?
          @currently_confirming == true
        end

        # In case email updates are being postponed, don't change anything
        # when the postpone feature tries to switch things back
        def email=(new_email)
          if currently_postponing_email_change?
            # Don't make any changes while postponement is being processed
            # because Devise sets `unconfirmed_email = email` and then
            # `email = email_was`
            new_email
          elsif currently_confirming? && new_email.present?
            # Devise is setting `email = unconfirmed_email` and then `unconfirmed_email = nil`
            # but the latter is skipped because we check if `new_email` is present
            multi_email.set_primary_record_to(
              multi_email.find_or_build_for_email(new_email),
              skip_confirmations: true
            )
          else
            multi_email.change_primary_email_to(new_email)
          end
        end
        alias_method :unconfirmed_email=, :email=

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
