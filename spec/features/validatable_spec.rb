require 'rails_helper'

RSpec.describe 'Validatable', type: :feature do
  before { visit new_user_session_path }

  describe 'User Sign Up' do
    it 'shows the error message when inputs are not valid' do
      click_link 'Sign up'
      expect(page).to have_selector('div', text: '(7 characters minimum)')

      fill_in 'user_email', with: '@test.com'
      fill_in 'user_password', with: 'lol'
      fill_in 'user_password_confirmation', with: 'lol'
      click_button 'Sign up'

      expect(page).to have_selector('div', text: 'Email is invalid')
      expect(page).to have_selector('div', text: 'Password is too short (minimum is 7 characters)')
    end
  end
end
