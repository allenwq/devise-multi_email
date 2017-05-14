
module Devise
  module MultiEmail
    class AssociationManager

      attr_reader :name

      def initialize(klass, association_name)
        @klass = klass
        @name = association_name
      end

      def include_module(mod)
        model_class.__send__ :include, mod
      end

      def model_class
        unless reflection
          raise "#{@klass}##{name} association not found: It might be because your declaration is after `devise :multi_email_confirmable`."
        end

        @model_class ||= reflection.class_name.constantize
      end

      def reflection
        @reflection ||= @klass.reflect_on_association(name)
      end
    end
  end
end
