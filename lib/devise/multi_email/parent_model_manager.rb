require 'devise/multi_email/email_model_extensions'

module Devise
  module MultiEmail
    class ParentModelManager

      def initialize(parent_record)
        @parent_record = parent_record
      end

      def before_commit_confirm_unconfirmed_email_when_not_postponed
        if !@parent_record.postponed_email_change? && unconfirmed_email_record && !unconfirmed_email_record.persisted?
          set_primary_record_to(unconfirmed_email_record, skip_confirmations: true)
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

      def unconfirmed_email_record
        unconfirmed_emails.first(&:new_record?) ||
        unconfirmed_emails.first
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
          return
        end

        formatted_email = format_email(new_email)
        record          = filtered_emails.find{ |item| item.email == formatted_email }

        if record.nil?
          if primary_email_record.nil? || options[:force_primary]
            set_primary_record_to(emails.build(email: formatted_email))
          elsif switching_to_unconfirmed_email?
            set_primary_record_to(emails.build(email: formatted_email), skip_confirmations: true)
          else
            # always create a new "unconfirmed email" record to make sure
            # `email_was` delegation always has a change when Devise needs it
            emails.build(email: formatted_email)
          end
        elsif record != primary_email_record
          if record.confirmed? || options[:force_primary]
            set_primary_record_to(record)
          elsif switching_to_unconfirmed_email?
            set_primary_record_to(record, skip_confirmations: true)
          else
            # NOTE: The only way to have non-primary emails which are not confirmed
            #       is to create them directly in the `emails` association of the parent.
            #       As of right now, the fact this email is specified is ignored and
            #       nothing is done to the record. Assume it's managed manually.
            # TODO: Determine if we allow to make unconfirmed emails already in the
            #       `emails` association the primary email. This would mean login would
            #       ask the user to confirm their email first....
          end
        end

        new_email
      end

      # See if any of the unconfirmed emails was recently created.
      # Could probably also check `persisted?`
      def was_email_changed?
        #unconfirmed_email.any?(&:email_changed?) rescue unconfirmed_email.any?(&:will_save_change_to_email?)
        !unconfirmed_email.all?(&:persisted?)
        end

      # Indicates if `confirm` is currently being called on the parent model
      # and the `email` and `unconfirmed_email` changes should be handled specially.
      # See `change_primary_email_to`
      def switching_to_unconfirmed_email?
        @parent_record.try(:currently_confirming?) == true
      end

      # See if any of the unconfirmed emails was recently created or changed.
      def unconfirmed_email_changes?
        !unconfirmed_emails.all?(&:persisted?) || unconfirmed_emails.any?(&:changed?)
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

      # Returns non-primary unconfirmed records.
      # Primary is excluded because presumably you will not
      # have any additional "unconfirmed" emails until the primary
      # email is confirmed.
      def unconfirmed_emails
        filtered_emails.lazy.reject(&:primary?).reject(&:confirmed?).to_a
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
