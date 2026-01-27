require 'devise/multi_email/email_model_extensions'

module Devise
  module MultiEmail
    class EmailModelManager

      def initialize(email_record)
        @email_record = email_record
      end

      def parent
        @email_record.__send__(@email_record.class.multi_email_association.name)
      end
    end
  end
end
