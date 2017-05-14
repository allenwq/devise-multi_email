require 'devise/multi_email/parent_model_extensions'

module Devise
  module Models
    module EmailAuthenticatable
      def devise_scope
        self.class.multi_email_association.model_class
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
          multi_email_association.include_module(EmailAuthenticatable)
        end

        delegate :skip_confirmation!, to: Devise::MultiEmail.primary_email_method_name, allow_nil: false

        # Gets the primary email address of the user.
        def email
          multi_email.primary_email.try(:email)
        end

        # Sets the default email address of the user.
        def email=(new_email)
          multi_email.change_primary_email_to(new_email)
        end
      end

      module ClassMethods
        def find_first_by_auth_conditions(tainted_conditions, opts = {})
          filtered_conditions = devise_parameter_filter.filter(tainted_conditions.dup)
          email = filtered_conditions.delete(:email)

          if email && email.is_a?(String)
            conditions = filtered_conditions.to_h.merge(opts).
              reverse_merge(multi_email_association.reflection.table_name => { email: email })

            resource = joins(multi_email_association.name).find_by(conditions)
            resource.current_login_email = email if resource.respond_to?(:current_login_email=)
            resource
          else
            super(tainted_conditions, opts)
          end
        end

        def find_by_email(email)
          joins(multi_email_association.name).where(multi_email_association.reflection.table_name => { email: email.downcase }).first
        end
      end
    end
  end
end
