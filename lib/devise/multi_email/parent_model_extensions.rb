require 'devise/multi_email/email_model_extensions'

module Devise
  module MultiEmail
    module ParentModelExtensions
      extend ActiveSupport::Concern

      included do
        _multi_email_emails_association_class.send :include, EmailModelExtensions

        alias_method _multi_email_primary_email_method_name, :_multi_email_find_primary_email
      end

      # Gets the email records that have not been deleted
      def _multi_email_filtered_emails
        _multi_email_emails_association.reject(&:destroyed?).reject(&:marked_for_destruction?)
      end

      # Gets the primary email record.
      def _multi_email_find_primary_email
        _multi_email_filtered_emails.find(&:primary?)
      end

      def _multi_email_change_email_to(new_email)
        valid_emails = _multi_email_filtered_emails
        # Use Devise formatting settings for emails
        formatted_email = self.class.send(:devise_parameter_filter).filter(email: new_email)[:email]

        # mark none as primary when set to nil
        if new_email.nil?
          valid_emails.each{ |record| record.primary = false }

        # select or build an email record
        else
          record = valid_emails.find{ |record| record.email == formatted_email }

          unless record
            record = _multi_email_emails_association.build(email: formatted_email)
            valid_emails << record
          end

          # toggle the selected record as primary and others as not
          valid_emails.each{ |other| other.primary = (other == record) }
        end

        record
      end

      def _multi_email_emails_association
        __send__(self.class._multi_email_emails_association_name)
      end

      module ClassMethods

        def _multi_email_emails_association_class
          unless _multi_email_reflect_on_emails_association
            raise "#{self}##{Devise::MultiEmail.emails_association_name} association not found: It might be because your declaration is after `devise :multi_email_confirmable`."
          end

          @_multi_email_emails_association_class ||= _multi_email_reflect_on_emails_association.class_name.constantize
        end

        def _multi_email_reflect_on_emails_association
          @_multi_email_reflect_on_emails_association ||= reflect_on_association(_multi_email_emails_association_name)
        end

        def _multi_email_emails_association_name
          Devise::MultiEmail.emails_association_name
        end

        def _multi_email_primary_email_method_name
          Devise::MultiEmail.primary_email_method_name
        end
      end
    end
  end
end
