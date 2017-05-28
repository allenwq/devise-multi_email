require 'devise/multi_email/email_model_extensions'

module Devise
  module MultiEmail
    class ParentModelManager

      def initialize(parent_record)
        @parent_record = parent_record
      end

      def current_email_record
        login_email_record || primary_email_record
      end

      def login_email_record
        if @parent_record.current_login_email.present?
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

      def change_primary_email_to(new_email)
        # mark none as primary when set to nil
        if new_email.nil?
          filtered_emails.each{ |item| item.primary = false }

        # select or build an email record
        else
          record = find_or_build_for_email(new_email)

          # toggle the selected record as primary and others as not
          filtered_emails.each{ |other| other.primary = (other == record) }
        end

        record
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
    end
  end
end
