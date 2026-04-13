require 'rails_helper'

RSpec.describe 'Encryptable compatibility' do
  describe 'Devise::ALL ordering' do
    it 'positions :multi_email_authenticatable before :encryptable' do
      multi_email_index = Devise::ALL.index(:multi_email_authenticatable)
      encryptable_index = Devise::ALL.index(:encryptable)

      expect(multi_email_index).to be < encryptable_index
    end

    it 'positions :multi_email_confirmable before :encryptable' do
      expect(Devise::ALL.index(:multi_email_confirmable)).to be < Devise::ALL.index(:encryptable)
    end

    it 'positions :multi_email_recoverable before :encryptable' do
      expect(Devise::ALL.index(:multi_email_recoverable)).to be < Devise::ALL.index(:encryptable)
    end

    it 'positions :multi_email_validatable before :encryptable' do
      expect(Devise::ALL.index(:multi_email_validatable)).to be < Devise::ALL.index(:encryptable)
    end
  end

  describe 'UserWithEncryptable model' do
    it 'includes Encryptable before DatabaseAuthenticatable in the ancestor chain' do
      encryptable_index = UserWithEncryptable.ancestors.index(Devise::Models::Encryptable)
      db_auth_index     = UserWithEncryptable.ancestors.index(Devise::Models::DatabaseAuthenticatable)

      expect(encryptable_index).to be < db_auth_index,
        'Encryptable must appear before DatabaseAuthenticatable in the ancestor chain ' \
        'so that Encryptable#valid_password? and Encryptable#password= take precedence'
    end

    describe 'password handling' do
      let(:email_address) { "encryptable_#{SecureRandom.hex}@test.com" }
      let(:password)      { 'encryptable_password' }

      let(:user) do
        u = UserWithEncryptable.new(
          email:                 email_address,
          password:              password,
          password_confirmation: password,
          created_at:            Time.now.utc,
          updated_at:            Time.now.utc
        )
        u.save!
        u
      end

      it 'sets password_salt when assigning a password' do
        expect(user.password_salt).to be_present
      end

      it 'stores a non-bcrypt encrypted_password' do
        # A bcrypt hash starts with "$2a$" or "$2b$"; with encryptable it should not
        expect(user.encrypted_password).not_to start_with('$2')
      end

      it 'validates the password correctly' do
        expect(user.valid_password?(password)).to be true
      end

      it 'rejects an incorrect password' do
        expect(user.valid_password?('wrong_password')).to be false
      end

      it 'finds the user by email via find_first_by_auth_conditions' do
        user  # ensure the record is persisted before searching
        found = UserWithEncryptable.find_first_by_auth_conditions(email: email_address)
        expect(found).to eq(user)
      end
    end
  end
end
