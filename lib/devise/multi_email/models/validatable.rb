module Devise
  module Models
    module EmailValidatable
      def self.included(base)
        base.extend ClassMethods

        base.class_eval do
          validates_presence_of   :email, if: :email_required?
          validates_uniqueness_of :email, allow_blank: true, if: :email_changed?
          validates_format_of     :email, with: email_regexp, allow_blank: true, if: :email_changed?
        end
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
        devise :validatable

        after_validation :propagate_email_errors
        email_class.send :include, EmailValidatable
      end

      private

      def email_changed?
        false
      end

      def propagate_email_errors
        return if (email_errors = errors.delete(self.class::EMAILS_ASSOCIATION)).nil?

        email_errors.each do |error|
          errors.add(:email, error)
        end
      end
    end
  end
end