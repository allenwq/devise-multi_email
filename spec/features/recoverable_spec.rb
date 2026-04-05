require 'rails_helper'

RSpec.describe 'Recoverable', type: :feature do
  before { ActionMailer::Base.deliveries.clear }

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
      let(:user) { create_user }
      let(:secondary_email) { create_email(user) }

      before do
        ActionMailer::Base.deliveries.clear
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

      it 'sends the password reset email to the primary email (default strategy)' do
        expect(ActionMailer::Base.deliveries.last.to).to eq [user.email]
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

  context 'when password_reset_email_strategy is :request (global config)' do
    around do |example|
      original = Devise::MultiEmail.password_reset_email_strategy
      Devise::MultiEmail.password_reset_email_strategy = :request
      example.run
    ensure
      Devise::MultiEmail.password_reset_email_strategy = original
    end

    let(:user) { create_user }
    let(:secondary_email) { create_email(user) }

    before do
      ActionMailer::Base.deliveries.clear
      visit_new_password_path
      request_forgot_password do
        fill_in 'user_email', with: secondary_email.email
      end
    end

    it 'sends the password reset email to the entered email address, not the primary email' do
      expect(ActionMailer::Base.deliveries.last.to).to eq [secondary_email.email]
    end
  end

  context 'when send_reset_password_instructions_notification is called with email: keyword' do
    let(:user) { create_user }
    let(:secondary_email) { create_email(user) }

    before { user.current_login_email = secondary_email.email }

    it 'sends to primary email when email: :primary' do
      index = ActionMailer::Base.deliveries.count
      user.send(:send_reset_password_instructions_notification, 'token', email: :primary)

      expect(ActionMailer::Base.deliveries[index].to).to eq [user.email]
    end

    it 'sends to the request email when email: :request' do
      index = ActionMailer::Base.deliveries.count
      user.send(:send_reset_password_instructions_notification, 'token', email: :request)

      expect(ActionMailer::Base.deliveries[index].to).to eq [secondary_email.email]
    end

    it 'uses the global config (:primary by default) when no email: keyword is given' do
      index = ActionMailer::Base.deliveries.count
      user.send(:send_reset_password_instructions_notification, 'token')

      expect(ActionMailer::Base.deliveries[index].to).to eq [user.email]
    end

    it 'uses global config :request when no email: keyword is given and strategy is :request' do
      Devise::MultiEmail.password_reset_email_strategy = :request
      index = ActionMailer::Base.deliveries.count
      user.send(:send_reset_password_instructions_notification, 'token')
      Devise::MultiEmail.password_reset_email_strategy = :primary

      expect(ActionMailer::Base.deliveries[index].to).to eq [secondary_email.email]
    end
  end
end
