class User < ActiveRecord::Base
  has_many :emails

  devise :multi_email_authenticatable, :multi_email_confirmable, :lockable, :multi_email_recoverable, :registerable,
         :rememberable, :timeoutable, :trackable, :multi_email_validatable
end
