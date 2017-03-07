class User < ApplicationRecord
  has_many :emails
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable and :omniauthable
  devise :multi_email_authenticatable, :multi_email_confirmable, :multi_email_validatable,
         :recoverable, :registerable, :rememberable, :trackable,
         # Below are for testing purpose, not required by default
         :encryptable, encryptor: :sha512
end
