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
    expect(page).to have_selector('div', text: 'You will receive an email with instructions for how to confirm your email address in a few minutes')
    expect(ActionMailer::Base.deliveries.size).to eq 1
    expect(ActionMailer::Base.deliveries.first.from).to eq ['please-change-me@config-initializers-devise.com']
  end

  it 'is able to confirm the account when confirmation token is valid' do
    user = create_user(confirm: false, confirmation_sent_at: 2.days.ago)
    expect(user).not_to be_confirmed
    visit_user_confirmation_with_token(user.primary_email_record.confirmation_token)

    expect(page).to have_selector('div', text: 'Your email address has been successfully confirmed.')
    expect(current_path).to eq '/users/sign_in'
    expect(user.reload).to be_confirmed
    expect(user.primary_email_record).to be_confirmed
  end

  describe '#email=' do
    context 'when unconfirmed access is disallowed' do
      it 'does not change primary email' do
        user = create_user
        first_email = user.primary_email_record
        user.email = generate_email

        expect(user.primary_email_record.email).to eq(first_email.email)
      end

      it 'changes primary email if confirmed' do
        user = create_user
        new_email = create_email(user, confirm: true)
        user.email = new_email.email

        expect(user.primary_email_record.email).to eq(new_email.email)
      end
    end

    context 'when unconfirmed access is allowed' do
      before do
        Devise.setup do |config|
          config.allow_unconfirmed_access_for = 2.days
        end
      end

      after do
        Devise.setup do |config|
          config.allow_unconfirmed_access_for = 0.day
        end
      end

      it 'changes primary email to the new email' do
        user = create_user
        new_email = generate_email
        user.email = new_email

        expect(user.primary_email_record.email).to eq(new_email)
      end

      context 'an unconfirmed access is indefinite' do
        before do
          Devise.setup do |config|
            config.allow_unconfirmed_access_for = nil
          end
        end

        it 'changes primary email to the new email' do
          user = create_user
          new_email = generate_email
          user.email = new_email

          expect(user.primary_email_record.email).to eq(new_email)
        end
      end
    end
  end

  describe 'Unconfirmed sign in' do
    context 'with primary email' do
      it 'shows the error message' do
        user = create_user(confirm: false)
        visit new_user_session_path

        fill_in 'user_email', with: user.email
        fill_in 'user_password', with: '12345678'
        click_button 'Log in'

        expect(current_path).to eq new_user_session_path
        expect(page).to have_selector('div#flash_alert', text: 'You have to confirm your email address before continuing.')
      end
    end

    context 'with non-primary email' do
      it 'shows the error message' do
        user = create_user
        secondary_email = create_email(user, confirm: false)
        visit new_user_session_path

        fill_in 'user_email', with: secondary_email.email
        fill_in 'user_password', with: '12345678'
        click_button 'Log in'

        expect(current_path).to eq new_user_session_path
        expect(page).to have_selector('div#flash_alert', text: 'You have to confirm your email address before continuing.')
      end
    end

    context 'when unconfirmed access is allowed' do
      before do
        Devise.setup do |config|
          config.allow_unconfirmed_access_for = 2.days
        end
      end

      after do
        Devise.setup do |config|
          config.allow_unconfirmed_access_for = 0.day
        end
      end

      context 'with primary email' do
        it 'signs the user in' do
          user = create_user(confirm: false)
          visit new_user_session_path

          fill_in 'user_email', with: user.email
          fill_in 'user_password', with: '12345678'
          click_button 'Log in'

          expect(current_path).to eq root_path
          expect(page).to have_selector('div', text: 'Signed in successfully.')
        end
      end

      context 'with non-primary email' do
        it 'shows the error message' do
          user = create_user
          secondary_email = create_email(user, confirm: false)
          visit new_user_session_path

          fill_in 'user_email', with: secondary_email.email
          fill_in 'user_password', with: '12345678'
          click_button 'Log in'

          expect(current_path).to eq new_user_session_path
          expect(page).to have_selector('div#flash_alert', text: 'You have to confirm your email address before continuing.')
        end
      end
    end
  end
end
