require 'devise/multi_email/version'
require 'devise'

module Devise
  module MultiEmail

    def self.configure(&block)
      yield self
    end

    def self.parent_association_name
      @parent_association_name ||= :user
    end

    def self.parent_association_name=(name)
      @parent_association_name = name.try(:to_sym)
    end

    def self.emails_association_name
      @emails_association_name ||= :emails
    end

    def self.emails_association_name=(name)
      @emails_association_name = name.try(:to_sym)
    end

    def self.primary_email_method_name
      @primary_email_method_name ||= :primary_email
    end

    def self.primary_email_method_name=(name)
      @primary_email_method_name = name.try(:to_sym)
    end

    module ParentModelExtensions
      extend ActiveSupport::Concern

      included do
        _multi_email_emails_association_class.send :include, EmailModelExtensions

        alias_method _multi_email_primary_email_method_name, :_multi_email_find_primary_email
      end

      # Gets the primary email record.
      def _multi_email_filtered_emails
        _multi_email_emails_association.reject(&:destroyed?).reject(&:marked_for_destruction?)
      end

      # Gets the primary email record.
      def _multi_email_find_primary_email
        _multi_email_filtered_emails.find(&:primary?)
      end

      def _multi_email_change_email_address(email_address)
        valid_emails = _multi_email_filtered_emails
        formatted_email_address = self.class.send(:devise_parameter_filter).filter(email: email_address)[:email]

        # mark none as primary when set to nil
        if email_address.nil?
          valid_emails.each{|record| record.primary = false}

        # select or create an email
        else
          record = valid_emails.find{|record| record.email == formatted_email_address}

          unless record
            record = _multi_email_emails_association.build(email: formatted_email_address)
            valid_emails << record
          end

          # toggle the selected record as primary and others as not
          valid_emails.each{|other| other.primary = (other == record)}
        end

        # if new_email.present?
        #   record ||= _multi_email_emails_association.build
        #   record.email = new_email
        #   # toggle primary to "true" for this record and "false" for the others
        #   _multi_email_emails_association.each{|other| other.primary = (other == record)}
        # elsif new_email.nil? && record
        #   record.mark_for_destruction
        # end

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

    module EmailModelExtensions
      extend ActiveSupport::Concern

      def _multi_email_parent_association
        __send__(self.class._multi_email_parent_association_name)
      end

      module ClassMethods

        def _multi_email_parent_association_class
          unless _multi_email_reflect_on_parent_association
            raise "#{self}##{Devise::MultiEmail.parent_association_name} association not found: It might be because your declaration is after `devise :multi_email_confirmable`."
          end

          @_multi_email_parent_association_class ||= _multi_email_reflect_on_parent_association.class_name.constantize
        end

        def _multi_email_reflect_on_parent_association
          @_multi_email_reflect_on_parent_association ||= reflect_on_association(_multi_email_parent_association_name)
        end

        def _multi_email_parent_association_name
          Devise::MultiEmail.parent_association_name
        end
      end
    end
  end
end

Devise.add_module :multi_email_authenticatable, model: 'devise/multi_email/models/authenticatable'
Devise.add_module :multi_email_confirmable, model: 'devise/multi_email/models/confirmable'
Devise.add_module :multi_email_validatable, model: 'devise/multi_email/models/validatable'
