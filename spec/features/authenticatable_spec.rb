require 'rails_helper'

RSpec.describe 'Authenticatable', type: :feature do
  describe 'User sign in' do
    context 'with primary email' do
      it 'signs the user in' do
        user = create_user
        visit new_user_session_path

        fill_in 'user_email', with: user.email
        fill_in 'user_password', with: '12345678'
        click_button 'Log in'

        expect(current_path).to eq root_path
        expect(page).to have_selector('div', text: 'Signed in successfully.')
      end
    end

    context 'with non-primary email' do
      before do
        Devise::MultiEmail.only_login_with_primary_email = false
      end
      after do
        Devise::MultiEmail.only_login_with_primary_email = false
      end

      it 'signs the user in when allowed to sign in with non-primary email' do
        user = create_user
        secondary_email = create_email(user)
        visit new_user_session_path

        fill_in 'user_email', with: secondary_email.email
        fill_in 'user_password', with: '12345678'
        click_button 'Log in'

        expect(current_path).to eq root_path
        expect(page).to have_selector('div', text: 'Signed in successfully.')
      end

      it 'does not sign the user in when not allowed to sign in with non-primary email' do
        Devise::MultiEmail.only_login_with_primary_email = true

        user = create_user
        secondary_email = create_email(user)
        visit new_user_session_path

        fill_in 'user_email', with: secondary_email.email
        fill_in 'user_password', with: '12345678'
        click_button 'Log in'

        expect(current_path).to eq new_user_session_path
        expect(page).to have_selector('div', text: 'Invalid Email or password.')
      end
    end

    context 'with upper case email' do
      it 'signs the user in' do
        user = create_user
        visit new_user_session_path

        fill_in 'user_email', with: user.email.upcase!
        fill_in 'user_password', with: '12345678'
        click_button 'Log in'

        expect(current_path).to eq root_path
        expect(page).to have_selector('div', text: 'Signed in successfully.')
      end
    end
  end

  describe 'User Has Multiple Emails' do
    context 'when changing primary email' do
      it 'toggles and persists primary value for all emails' do
        user = create_user
        second_email = create_email(user)
        third_email = create_email(user)

        user.save

        expect(user.errors.size).to eq 0
        expect(user.emails.all?(&:persisted?)).to eq true
        expect(user.emails.any?(&:changed?)).to eq false

        user.email = second_email.email
        user.email = third_email.email

        expect(user.emails.select(&:primary?).size).to eq 1

        user.save
        user.reload
        user.emails.reload

        expect(user.emails.select(&:primary?).size).to eq 1
        expect(user.multi_email.primary_email_record.email).to eq third_email.email
      end
    end
  end
end
