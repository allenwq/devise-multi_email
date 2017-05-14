
module Devise
  module MultiEmail
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
