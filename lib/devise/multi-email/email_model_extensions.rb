require 'devise/multi_email/association_manager'
require 'devise/multi_email/email_model_manager'

module Devise
  module MultiEmail
    module EmailModelExtensions
      extend ActiveSupport::Concern

      def multi_email
        @multi_email ||= EmailModelManager.new(self)
      end

      module ClassMethods
        def multi_email_association
          @multi_email ||= AssociationManager.new(self, Devise::MultiEmail.parent_association_name)
        end
      end
    end
  end
end
