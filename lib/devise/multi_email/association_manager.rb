
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

      # Specify a block with alternative behavior which should be
      # run when `autosave` is not enabled.
      def configure_autosave!(&block)
        unless autosave_changes?
          if Devise::MultiEmail.configure_autosave
            reflection.autosave = true
          end

          yield if block_given?
        end
      end

      def autosave_changes?
        reflection.options[:autosave] == true
      end

      def model_class
        @model_class ||= reflection.class_name.constantize
      end

      def reflection
        @reflection ||= @klass.reflect_on_association(name) ||
                        raise("#{@klass}##{name} association not found: It might be because your declaration is after `devise :multi_email_confirmable`.")
      end
    end
  end
end
