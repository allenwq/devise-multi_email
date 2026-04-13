class UserWithEncryptable < ActiveRecord::Base
  self.table_name = 'users'
  has_many :emails, foreign_key: :user_id

  devise :multi_email_authenticatable, :encryptable, encryptor: :sha512
end
