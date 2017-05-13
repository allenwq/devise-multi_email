module Devise
  module Models
    module EmailValidatable
      extend ActiveSupport::Concern

      included do
        validates_presence_of   :email, if: :email_required?
        validates_uniqueness_of :email, allow_blank: true, if: :email_changed?
        validates_format_of     :email, with: email_regexp, allow_blank: true, if: :email_changed?
      end

      def email_required?
        true
      end

      module ClassMethods
        Devise::Models.config(self, :email_regexp)
      end
    end

    module MultiEmailValidatable
      extend ActiveSupport::Concern

      included do
        include Devise::MultiEmail::ParentModelExtensions

        assert_validations_api!(self)

        validates_presence_of     :email, if: :email_required?

        validates_presence_of     :password, if: :password_required?
        validates_confirmation_of :password, if: :password_required?
        validates_length_of       :password, within: password_length, allow_blank: true

        after_validation :propagate_email_errors

        _multi_email_emails_association_class.send :include, EmailValidatable

        devise_modules << :validatable
      end

      def self.required_fields(klass)
        []
      end

    protected

      # Same as Devise::Models::Validatable#password_required?
      def password_required?
        !persisted? || !password.nil? || !password_confirmation.nil?
      end

      # Same as Devise::Models::Validatable#email_required?
      def email_required?
        true
      end

    private

      def propagate_email_errors
        email_error_key = self.class._multi_email_emails_association_name

        if respond_to?("#{email_error_key}_attributes=")
          email_error_key = "#{email_error_key}.email".to_sym
        end

        email_errors = errors.delete(email_error_key) || []

        email_errors.each do |error|
          errors.add(:email, error)
        end
      end

      module ClassMethods

        # All validations used by this module.
        VALIDATIONS = [:validates_presence_of, :validates_uniqueness_of, :validates_format_of,
                       :validates_confirmation_of, :validates_length_of].freeze

        def assert_validations_api!(base) #:nodoc:
          unavailable_validations = VALIDATIONS.select { |v| !base.respond_to?(v) }

          unless unavailable_validations.empty?
            raise "Could not use :validatable module since #{base} does not respond " <<
                  "to the following methods: #{unavailable_validations.to_sentence}."
          end
        end

        Devise::Models.config(self, :password_length)
      end
    end
  end
end
