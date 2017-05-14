require 'devise/multi_email/email_model_extensions'

module Devise
  module MultiEmail
    class EmailModelManager

      attr_reader :record

      def initialize(record)
        @record = record
      end

      def parent
        record.__send__(record.class.multi_email_association.name)
      end
    end
  end
end
