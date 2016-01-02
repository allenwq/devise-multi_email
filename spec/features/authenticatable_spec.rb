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
        expect(page).to have_selector('div', 'You are now signed in.')
      end

      context 'when not confirmed' do
        it 'shows the error message' do
          user = create_user(confirm: false)
          visit new_user_session_path

          fill_in 'user_email', with: user.email
          fill_in 'user_password', with: '12345678'
          click_button 'Log in'

          expect(current_path).to eq new_user_session_path
          expect(page).to have_selector('div#flash_alert', 'You have to confirm your email address before continuing.')
        end
      end
    end

    context 'with non-primary email' do
      it 'signs the user in' do
        user = create_user
        secondary_email = create_email(user)
        visit new_user_session_path

        fill_in 'user_email', with: secondary_email.email
        fill_in 'user_password', with: '12345678'
        click_button 'Log in'

        expect(current_path).to eq root_path
        expect(page).to have_selector('div', 'You are now signed in.')
      end

      context 'when not confirmed' do
        it 'shows the error message' do
          pending 'To implement'
          user = create_user
          secondary_email = create_email(user, confirm: false)
          visit new_user_session_path

          fill_in 'user_email', with: secondary_email.email
          fill_in 'user_password', with: '12345678'
          click_button 'Log in'

          expect(current_path).to eq new_user_session_path
          expect(page).to have_selector('div#flash_alert', 'You have to confirm your email address before continuing.')
        end
      end
    end
  end
end
