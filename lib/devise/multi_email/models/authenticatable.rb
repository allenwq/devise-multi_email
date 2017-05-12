module Devise
  module Models
    module EmailAuthenticatable
      # deprecated
      USER_ASSOCIATION = Devise::MultiEmail.parent_association_name

      def devise_scope
        user_association = self.class.reflect_on_association(Devise::MultiEmail.parent_association_name)
        if user_association
          user_association.class_name.constantize
        else
          raise "#{self.class.name}: Association :#{Devise::MultiEmail.parent_association_name} not found: Have you declared that ?"
        end
      end
    end

    module MultiEmailAuthenticatable
      extend ActiveSupport::Concern
      # deprecated
      EMAILS_ASSOCIATION = Devise::MultiEmail.emails_association_name

      included do
        devise :database_authenticatable

        attr_accessor :current_login_email

        email_class.send :include, EmailAuthenticatable
      end

      def self.required_fields(klass)
        []
      end

      # Gets the primary email record.
      def primary_email_record
        valid_emails = __send__(Devise::MultiEmail.emails_association_name).each.select do |email_record|
          !email_record.destroyed? && !email_record.marked_for_destruction?
        end

        result = valid_emails.find(&:primary?)
        result ||= valid_emails.first
        result
      end

      # Gets the primary email address of the user.
      def email
        primary_email_record.try(:email)
      end

      # Sets the default email address of the user.
      def email=(email)
        record = primary_email_record
        if email
          record ||= __send__(Devise::MultiEmail.emails_association_name).build
          record.email = email
          record.primary = true
        elsif email.nil? && record
          record.mark_for_destruction
        end
      end

      # skip_confirmation on the users primary email
      def skip_confirmation!
        primary_email_record.skip_confirmation!
      end

      module ClassMethods
        def find_first_by_auth_conditions(tainted_conditions, opts = {})
          filtered_conditions = devise_parameter_filter.filter(tainted_conditions.dup)
          email = filtered_conditions.delete(:email)

          if email && email.is_a?(String)
            conditions = filtered_conditions.to_h.merge(opts).
              reverse_merge(Devise::MultiEmail.emails_association_name => { email: email })

            resource = joins(Devise::MultiEmail.emails_association_name).find_by(conditions)
            resource.current_login_email = email if resource.respond_to?(:current_login_email=)
            resource
          else
            super(tainted_conditions, opts)
          end
        end

        def email_class
          email_association = reflect_on_association(Devise::MultiEmail.emails_association_name)
          if email_association
            email_association.class_name.constantize
          else
            raise "#{self.class.name}: Association :#{Devise::MultiEmail.emails_association_name} not found: It might because your declaration is after `devise :multi_email_confirmable`."
          end
        end

        def find_by_email(email)
          joins(Devise::MultiEmail.emails_association_name).where(Devise::MultiEmail.emails_association_name => {email: email.downcase}).first
        end
      end
    end
  end
end
