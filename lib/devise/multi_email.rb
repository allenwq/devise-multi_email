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
        _emails_association_class.send :include, EmailModelExtensions

        alias_method _primary_email_method_name, :_find_or_build_primary_email
      end

      # Gets the primary email record.
      def _find_or_build_primary_email
        valid_emails = _emails_association.each.select do |email_record|
          !email_record.destroyed? && !email_record.marked_for_destruction?
        end

        result = valid_emails.find(&:primary?)
        result ||= valid_emails.first
        result
      end

      def _emails_association
        __send__(self.class._emails_association_name)
      end

      module ClassMethods

        def _emails_association_class
          unless _reflect_on_emails_association
            raise "#{self}##{Devise::MultiEmail.emails_association_name} association not found: It might be because your declaration is after `devise :multi_email_confirmable`."
          end

          @_emails_association_class ||= _reflect_on_emails_association.class_name.constantize
        end

        def _emails_association_table_name
          @_emails_association_table_name ||= _reflect_on_emails_association.table_name
        end

        def _reflect_on_emails_association
          @_reflect_on_emails_association ||= reflect_on_association(_emails_association_name)
        end

        def _emails_association_name
          Devise::MultiEmail.emails_association_name
        end

        def _primary_email_method_name
          Devise::MultiEmail.primary_email_method_name
        end
      end
    end

    module EmailModelExtensions
      extend ActiveSupport::Concern

      def _parent_association
        __send__(self.class._parent_association_name)
      end

      module ClassMethods

        def _parent_association_class
          unless _reflect_on_parent_association
            raise "#{self}##{Devise::MultiEmail.parent_association_name} association not found: It might be because your declaration is after `devise :multi_email_confirmable`."
          end

          @_parent_association_class ||= _reflect_on_parent_association.class_name.constantize
        end

        def _parent_association_table_name
          @_parent_association_table_name ||= _reflect_on_parent_association.table_name
        end

        def _reflect_on_parent_association
          @_reflect_on_parent_association ||= reflect_on_association(_parent_association_name)
        end

        def _parent_association_name
          Devise::MultiEmail.parent_association_name
        end
      end
    end
  end
end

Devise.add_module :multi_email_authenticatable, model: 'devise/multi_email/models/authenticatable'
Devise.add_module :multi_email_confirmable, model: 'devise/multi_email/models/confirmable'
Devise.add_module :multi_email_validatable, model: 'devise/multi_email/models/validatable'
