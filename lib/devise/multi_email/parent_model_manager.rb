require 'devise/multi_email/email_model_extensions'

module Devise
  module MultiEmail
    class ParentModelManager

      def initialize(parent_record)
        @parent_record = parent_record
      end

      def before_commit_confirm_unconfirmed_email_when_not_postponed
        if !@parent_record.postponed_email_change? && primary_email_record.unconfirmed_email.present?
          change_primary_email_to(primary_email_record.unconfirmed_email, switching_to_unconfirmed_email: true)
        end
      end

      def current_email_record
        login_email_record || primary_email_record
      end

      def login_email_record
        if @parent_record.try(:current_login_email)
          formatted_email = format_email(@parent_record.current_login_email)

          filtered_emails.find{ |item| item.email == formatted_email }
        end
      end

      # Gets the primary email record.
      def primary_email_record
        filtered_emails.find(&:primary?)
      end
      alias_method Devise::MultiEmail.primary_email_method_name, :primary_email_record

      # If an email address does not exist, it's stored as `unconfirmed_email`.
      # Once confirmed, it gets added to the list of alternate emails.
      #
      # :make_primary option sets this email record to primary
      # :skip_confirmations option confirms this email record (without saving)
      # @see `set_primary_record_to`
      def change_primary_email_to(new_email, options = {})
        # don't change anything when the postpone feature tries to switch things back
        return new_email if @parent_record.try(:currently_postponing_email_change?)

        # mark none as primary when set to nil
        if new_email.nil?
          filtered_emails.each{ |item| item.primary = false }

        # select or build an email record
        else
          formatted_email = format_email(new_email)

          record = filtered_emails.find{ |item| item.email == formatted_email }

          if record.nil?
            if primary_email_record.nil? || options[:force_primary]
              record = emails.build(email: formatted_email, primary: true)
              change_unconfirmed_email_to(nil)
            elsif options[:switching_to_unconfirmed_email] || switching_to_unconfirmed_email?
              record = emails.build(email: formatted_email, primary: true)
              record.skip_confirmation!
              record.skip_reconfirmation!
              filtered_emails.each{ |other| other.primary = (other.email == record.email) }
              change_unconfirmed_email_to(nil)
            else
              # always create a new "unconfirmed email" record to make sure
              # `email_was` delegation always has a change when Devise needs it
              change_unconfirmed_email_to(new_email)
            end
          elsif record != primary_email_record
            if record.confirmed? || options[:force_primary]
              filtered_emails.each{ |other| other.primary = (other.email == record.email) }
              change_unconfirmed_email_to(nil)
            elsif options[:switching_to_unconfirmed_email] || switching_to_unconfirmed_email?
              record.skip_confirmation!
              record.skip_reconfirmation!
              filtered_emails.each{ |other| other.primary = (other.email == record.email) }
              change_unconfirmed_email_to(nil)
            else
              # NOTE: There shouldn't be a non-primary email that is not confirmed
            end
          end
        end

        new_email
      end

      def change_unconfirmed_email_to(new_email)
        # Don't change anything when the "postpone" feature tries to swap `email` and `unconfirmed_email`.
        # Set `unconfirmed_email` on all email records to the same value to retain the unconfirmed email
        # when the primary record changes.
        unless @parent_record.try(:currently_postponing_email_change?)
          emails.each{ |item| item.unconfirmed_email = new_email }
        end

        new_email
      end

      # Use `unconfirmed_email` as surrogate on parent model to indicate if email was changed,
      # which can trigger the postpone email change functionaliy.
      def was_email_changed?
        !!(primary_email_record.try(:unconfirmed_email_changed?) || primary_email_record.try(:will_save_change_to_unconfirmed_email?))
      end

      # Indicates if `confirm` is currently being called on the parent model
      # and the `email` and `unconfirmed_email` changes should be handled specially.
      # See `change_primary_email_to`
      def switching_to_unconfirmed_email?
        @parent_record.currently_confirming?
      end

      # Use Devise formatting settings for emails
      def format_email(email)
        @parent_record.class.__send__(:devise_parameter_filter).filter(email: email)[:email]
      end

      def find_or_build_for_email(email)
        formatted_email = format_email(email)
        record = filtered_emails.find{ |item| item.email == formatted_email }

        record || emails.build(email: formatted_email)
      end

      def emails
        @parent_record.__send__(@parent_record.class.multi_email_association.name)
      end

    protected

      # Gets the email records that have not been deleted
      def filtered_emails
        emails.lazy.reject(&:destroyed?).reject(&:marked_for_destruction?).to_a
      end

      # :skip_confirmations option confirms this email record (without saving)
      def set_primary_record_to(record, options = {})
        # Toggle primary flag for all emails
        filtered_emails.each{ |other| other.primary = (other.email == record.email) }

        if options[:skip_confirmations]
          record.try(:skip_confirmation!)
          record.try(:skip_reconfirmation!)
        end
      end
    end
  end
end
