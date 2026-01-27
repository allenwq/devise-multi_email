require 'devise/multi_email/email_model_extensions'
require 'devise/multi_email/association_manager'
require 'devise/multi_email/parent_model_manager'

module Devise
  module MultiEmail
    module ParentModelExtensions
      extend ActiveSupport::Concern

      included do
        multi_email_association.configure_autosave!
        multi_email_association.include_module(EmailModelExtensions)
      end

      delegate Devise::MultiEmail.primary_email_method_name, to: :multi_email, allow_nil: false

      def multi_email
        @multi_email ||= ParentModelManager.new(self)
      end

      module ClassMethods
        def multi_email_association
          @multi_email ||= AssociationManager.new(self, Devise::MultiEmail.emails_association_name)
        end
      end
    end
  end
end
