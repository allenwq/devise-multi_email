require 'rails_helper'

RSpec.describe 'Confirmable', type: :feature do
  def visit_user_confirmation_with_token(confirmation_token)
    visit user_confirmation_path(confirmation_token: confirmation_token)
  end

  def resend_confirmation
    user = create_user(confirm: false)
    ActionMailer::Base.deliveries.clear

    visit new_user_session_path
    click_link "Didn't receive confirmation instructions?"

    fill_in 'user_email', with: user.email
    click_button 'Resend confirmation instructions'
  end

  it 'is able to request a new confirmation' do
    resend_confirmation

    expect(current_path).to eq '/users/sign_in'
    expect(page).to have_selector('div', 'You will receive an email with instructions for how to confirm your email address in a few minutes')
    expect(ActionMailer::Base.deliveries.size).to eq 1
    expect(ActionMailer::Base.deliveries.first.from).to eq ['please-change-me@config-initializers-devise.com']
  end

  it 'is able to confirm the account when confirmation token is valid' do
    user = create_user(confirm: false, confirmation_sent_at: 2.days.ago)
    expect(user).not_to be_confirmed
    visit_user_confirmation_with_token(user.primary_email_record.confirmation_token)

    expect(page).to have_selector('div', 'Your email address has been successfully confirmed.')
    expect(current_path).to eq '/users/sign_in'
    expect(user.reload).to be_confirmed
    expect(user.primary_email_record).to be_confirmed
  end
end
