module Devise
  module Models
    module MultiEmailAuthenticatable
      extend ActiveSupport::Concern

      included do
        devise :database_authenticatable

        attr_accessor :current_login_email
      end

      def self.required_fields(klass)
        []
      end

      # Gets the primary email record.
      def primary_email_record
        valid_emails = emails.each.select do |email_record|
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
          record ||= emails.build
          record.email = email
          record.primary = true
        elsif email.nil? && record
          record.mark_for_destruction
        end
      end

      module ClassMethods
        def find_first_by_auth_conditions(tainted_conditions, opts = {})
          email = tainted_conditions.delete(:email)
          if email && email.is_a?(String)
            conditions = devise_parameter_filter.filter(tainted_conditions).to_h.merge(opts).
                reverse_merge(emails: { email: email })

            resource = joins(:emails).find_by(conditions)
            resource.current_login_email = email if resource.respond_to?(:current_login_email=)
            resource
          else
            super(tainted_conditions, opts)
          end
        end
      end
    end
  end
end