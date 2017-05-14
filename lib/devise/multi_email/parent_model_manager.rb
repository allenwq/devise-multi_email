require 'devise/multi_email/email_model_extensions'

module Devise
  module MultiEmail
    class ParentModelManager

      attr_reader :record

      def initialize(record)
        @record = record
      end

      # Gets the email records that have not been deleted
      def filtered_emails
        emails.reject(&:destroyed?).reject(&:marked_for_destruction?)
      end

      # Gets the primary email record.
      def primary_email
        filtered_emails.find(&:primary?)
      end
      alias_method Devise::MultiEmail.primary_email_method_name, :primary_email

      def change_primary_email_to(new_email)
        # Use Devise formatting settings for emails
        formatted_email = record.class.send(:devise_parameter_filter).filter(email: new_email)[:email]

        valid_emails = filtered_emails

        # mark none as primary when set to nil
        if new_email.nil?
          valid_emails.each{ |record| record.primary = false }

        # select or build an email record
        else
          record = valid_emails.find{ |record| record.email == formatted_email }

          unless record
            record = emails.build(email: formatted_email)
            valid_emails << record
          end

          # toggle the selected record as primary and others as not
          valid_emails.each{ |other| other.primary = (other == record) }
        end

        record
      end

      def emails
        record.__send__(record.class.multi_email_association.name)
      end
    end
  end
end
