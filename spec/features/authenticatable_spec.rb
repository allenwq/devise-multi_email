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
end
