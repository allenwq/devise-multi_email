class User < ActiveRecord::Base
  has_many :emails

  devise :multi_email_authenticatable, :multi_email_confirmable, :lockable, :recoverable, :registerable,
         :rememberable, :timeoutable, :trackable, :multi_email_validatable, password_length: 7..72
end
