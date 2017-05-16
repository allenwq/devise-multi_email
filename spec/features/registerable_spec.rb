require 'rails_helper'

RSpec.describe 'Registerable', type: :feature do
  before { visit new_user_session_path }

  describe 'User Sign Up' do
    it 'creates an account which is blocked by confirmation' do
      click_link 'Sign up'

      fill_in 'user_email', with: 'new_user@test.com'
      fill_in 'user_password', with: 'new_user123'
      fill_in 'user_password_confirmation', with: 'new_user123'
      expect { click_button 'Sign up' }.to change(ActionMailer::Base.deliveries, :count).by(1)
      
      expect(page).to have_selector('div', text: 'A message with a confirmation link has been sent to your email address. Please follow the link to activate your account.')

      user = User.last
      expect(user.email).to eq 'new_user@test.com'
      expect(user).not_to be_confirmed
    end
  end
end
