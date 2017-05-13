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

        attr_accessor :current_login_email

        devise :database_authenticatable

        include AuthenticatableExtensions
      end

      def self.required_fields(klass)
        []
      end

      module AuthenticatableExtensions
        extend ActiveSupport::Concern

        included do
          _multi_email_emails_association_class.send :include, EmailAuthenticatable
        end

        delegate :skip_confirmation!, to: :_multi_email_find_primary_email, allow_nil: false

        # Gets the primary email address of the user.
        def email
          _multi_email_find_primary_email.try(:email)
        end

        # Sets the default email address of the user.
        def email=(new_email)
          _multi_email_change_email_address(new_email)
        end
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
