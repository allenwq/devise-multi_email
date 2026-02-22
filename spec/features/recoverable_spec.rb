require 'rails_helper'

RSpec.describe 'Recoverable', type: :feature do
  def visit_new_password_path
    visit new_user_session_path
    click_link 'Forgot your password?'
  end

  def request_forgot_password
    visit_new_password_path

    fill_in 'user_email', with: 'user@test.com'
    yield if block_given?

    click_button 'Send me password reset instructions'
  end

  context 'with primary email' do
    it 'sends the password reset email' do
      user = create_user
      visit_new_password_path

      request_forgot_password do
        fill_in 'user_email', with: user.email
      end

      expect(current_path).to eq new_user_session_path
      expect(page).to have_selector('div',
                                    text: 'You will receive an email with instructions on how to reset your password in a few minutes.')
    end

    context 'when not confirmed' do
      it 'shows the error message' do
        user = create_user(confirm: false)
        visit_new_password_path

        request_forgot_password do
          fill_in 'user_email', with: user.email
        end

        expect(current_path).to eq new_user_session_path
        expect(page).to have_selector('div',
                                      text: 'You will receive an email with instructions on how to reset your password in a few minutes.')
      end
    end
  end

  context 'with non-primary email' do
    context 'when confirmed' do
      before do
        user = create_user
        secondary_email = create_email(user)
        visit_new_password_path

        request_forgot_password do
          fill_in 'user_email', with: secondary_email.email
        end
      end

      it 'sends the password reset email' do
        expect(current_path).to eq new_user_session_path
        expect(page).to have_selector('div',
                                      text: 'You will receive an email with instructions on how to reset your password in a few minutes.')
      end

      it 'redirects to password reset page when visiting the link' do
        link = ActionMailer::Base.deliveries.last.body.to_s.scan(/<a\s[^>]*href="([^"]*)"/x)[0][0]
        visit link

        fill_in 'user_password', with: 'abcdefgh'
        fill_in 'user_password_confirmation', with: 'abcdefgh'
        click_button 'Change my password'

        expect(page).to have_selector('div',
                                      text: 'Your password has been changed successfully. You are now signed in.')
      end
    end

    context 'when not confirmed' do
      it 'shows the error message' do
        user = create_user
        secondary_email = create_email(user, confirm: false)
        visit_new_password_path

        request_forgot_password do
          fill_in 'user_email', with: secondary_email.email
        end

        expect(current_path).to eq new_user_session_path
        expect(page).to have_selector('div',
                                      text: 'You will receive an email with instructions on how to reset your password in a few minutes.')
      end
    end
  end

  context 'with non-existing email' do
    before do
      visit_new_password_path

      request_forgot_password do
        fill_in 'user_email', with: "#{SecureRandom.base64}@example.com"
      end
    end

    it 'shows email does not exist' do
      expect(current_path).to eq '/users/password'
      expect(page).to have_selector('div', text: 'Email not found')
    end
  end
end
