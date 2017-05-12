module Devise
  module Models
    module EmailAuthenticatable
      def devise_scope
        self.class._multi_email_parent_association_class
      end
    end

    module MultiEmailAuthenticatable
      extend ActiveSupport::Concern

      included do
        include Devise::MultiEmail::ParentModelExtensions

        devise :database_authenticatable

        attr_accessor :current_login_email

        _multi_email_emails_association_class.send :include, EmailAuthenticatable
      end

      def self.required_fields(klass)
        []
      end

      # Gets the primary email address of the user.
      def email
        _multi_email_find_or_build_primary_email.try(:email)
      end

      # Sets the default email address of the user.
      def email=(email)
        record = _multi_email_find_or_build_primary_email
        if email
          record ||= _multi_email_emails_association.build
          record.email = email
          record.primary = true
        elsif email.nil? && record
          record.mark_for_destruction
        end
      end

      # skip_confirmation on the users primary email
      def skip_confirmation!
        _multi_email_find_or_build_primary_email.skip_confirmation!
      end

      module ClassMethods
        def find_first_by_auth_conditions(tainted_conditions, opts = {})
          filtered_conditions = devise_parameter_filter.filter(tainted_conditions.dup)
          email = filtered_conditions.delete(:email)

          if email && email.is_a?(String)
            conditions = filtered_conditions.to_h.merge(opts).
              reverse_merge(_multi_email_reflect_on_emails_association.table_name => { email: email })

            resource = joins(_multi_email_emails_association_name).find_by(conditions)
            resource.current_login_email = email if resource.respond_to?(:current_login_email=)
            resource
          else
            super(tainted_conditions, opts)
          end
        end

        def find_by_email(email)
          joins(_multi_email_emails_association_name).where(_multi_email_reflect_on_emails_association.table_name => {email: email.downcase}).first
        end
      end
    end
  end
end
