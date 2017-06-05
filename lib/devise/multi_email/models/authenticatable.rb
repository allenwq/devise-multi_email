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
          multi_email_association.configure_autosave!{ include AuthenticatableAutosaveExtensions }
          multi_email_association.include_module(EmailAuthenticatable)
        end

        delegate :skip_confirmation!, to: Devise::MultiEmail.primary_email_method_name, allow_nil: false

        # Gets the primary email address of the user.
        def email
          multi_email.primary_email_record.try(:email)
        end

        # Sets the default email address of the user.
        def email=(new_email)
          multi_email.change_primary_email_to(new_email, allow_unconfirmed: true)
        end
      end

      module AuthenticatableAutosaveExtensions
        extend ActiveSupport::Concern

        included do
          primary_column = connection.quote_column_name(:primary)
          id_column      = connection.quote_column_name(:id)

          # Toggle `primary` value for all emails if `autosave` is not on
          after_save do
            if multi_email.primary_email_record
              multi_email.emails.update_all([
                "#{primary_column} = (CASE #{id_column} WHEN ? THEN 1 ELSE 0 END)",
                multi_email.primary_email_record.id
              ])
            else
              multi_email.emails.update_all(primary: false)
            end
          end
        end
      end

      module ClassMethods
        def find_first_by_auth_conditions(tainted_conditions, opts = {})
          filtered_conditions = devise_parameter_filter.filter(tainted_conditions.dup)
          criteria = filtered_conditions.extract!(:email, :unconfirmed_email)

          if criteria.keys.any?
            conditions = filtered_conditions.to_h.merge(opts).
              reverse_merge(build_conditions(criteria))

            resource = joins(multi_email_association.name).find_by(conditions)
            resource.current_login_email = criteria.values.first if resource
            resource
          else
            super(tainted_conditions, opts)
          end
        end

        def find_by_email(email)
          joins(multi_email_association.name).where(build_conditions email: email).first
        end

        def build_conditions(criteria)
          criteria = devise_parameter_filter.filter(criteria)
          # match the primary email record if the `unconfirmed_email` column is specified
          if Devise::MultiEmail.only_login_with_primary_email || criteria[:unconfirmed_email]
            criteria.merge!(primary: true)
          end

          { multi_email_association.reflection.table_name.to_sym => criteria }
        end
      end
    end
  end
end
