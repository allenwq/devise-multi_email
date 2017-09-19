class Email < ApplicationRecord
  belongs_to :user

  table_name 'user_emails'
end
