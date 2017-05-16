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

          # Handle automatically confirming and linking `unconfirmed_email` if email change is not postponed
          before_update 'multi_email.before_commit_confirm_unconfirmed_email_when_not_postponed'

          # Don't send notifications when the email records are saved
          # when saving the parent record.
          if respond_to?(:after_commit)
            after_commit 'multi_email.primary_email_record.skip_confirmation_notification!', prepend: true
          else # Mongoid
            after_create 'multi_email.primary_email_record.skip_confirmation_notification!', prepend: true
            after_update 'multi_email.primary_email_record.skip_confirmation_notification!', prepend: true
          end
        end

        delegate :unconfirmed_email, :confirmation_token, :confirmation_token=,
                 :confirmed_at, :confirmed_at=, :confirmation_sent_at, :confirmation_sent_at=,
                 to: 'multi_email.current_email_record', allow_nil: true

        delegate :active_for_authentication?, to: 'multi_email.current_email_record', allow_nil: false

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
        # See `multi_email#change_unconfirmed_email_to`
        def postpone_email_change_until_confirmation_and_regenerate_confirmation_token
          @currently_postponing_email_change = true
            super
        ensure
          @currently_postponing_email_change = false
          end

        # Override to set flags that indicate confirmation is currently happening.
        # See `multi_email#switching_to_unconfirmed_email?`
        def confirm(*args)
          @currently_confirming = true
            super
        ensure
          @currently_confirming = false
        end

        # Indicates if the email is currently being confirmed
        # See `multi_email#switching_to_unconfirmed_email?`
        def currently_confirming?
          @currently_confirming == true
        end

        # In case email updates are being postponed, don't change anything
        # when the postpone feature tries to switch things back
        def email=(new_email)
          multi_email.change_primary_email_to(new_email, force_primary: false)
        end

        def unconfirmed_email=(value)
          multi_email.change_unconfirmed_email_to(value)
        end

        # Used to indicate if email changes should be posponed (Rails >= 5)
        def will_save_change_to_email?
          multi_email.was_email_changed?
        end

        # Used to indicate if email changes should be postponed (Rails < 5)
        def email_changed?
          multi_email.was_email_changed?
        end

      private

        module ClassMethods
          delegate :confirm_by_token, to: 'multi_email_association.model_class', allow_nil: false
        end
      end
    end
  end
end
