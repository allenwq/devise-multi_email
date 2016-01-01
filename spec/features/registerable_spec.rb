require 'spec_helper'

RSpec.describe 'Registerable', type: :feature do
  before { visit new_user_session_path }

  it 'shows the page' do
    click_link 'Sign up'

    fill_in 'user_email', with: 'new_user@test.com'
    fill_in 'user_password', with: 'new_user123'
    fill_in 'user_password_confirmation', with: 'new_user123'
    click_button 'Sign up'
  end
end
