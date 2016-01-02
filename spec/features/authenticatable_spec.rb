require 'spec_helper'

RSpec.describe 'Authenticatable', type: :feature do
  describe 'User sign in' do
    it 'signs the user in' do
      user = create_user
      visit new_user_session_path

      fill_in 'user_email', with: user.email
      fill_in 'user_password', with: '12345678'
      click_button 'Log in'

      expect(current_path).to eq root_path
      expect(page).to have_selector('div', 'You are now signed in.')
    end

    it 'shows the error message when email is not confirmed' do
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
