module RailsTestHelpers
  def create_user(options={})
    user = User.create!(
        username: 'usertest',
        email: options[:email] || "user_#{SecureRandom.hex}@test.com",
        password: options[:password] || '12345678',
        password_confirmation: options[:password] || '12345678',
        created_at: Time.now.utc
    )
    user.primary_email_record.update_attribute(:confirmation_sent_at, options[:confirmation_sent_at]) if options[:confirmation_sent_at]
    user.confirm unless options[:confirm] == false
    user
  end

  def create_email(user, options = {})
    email = user._emails_association.create!(
      email: options[:email] || "user_#{SecureRandom.hex}@test.com",
      created_at: Time.now.utc
    )
    email.update_attribute(:confirmation_sent_at, options[:confirmation_sent_at]) if options[:confirmation_sent_at]
    email.confirm unless options[:confirm] == false
    email
  end

  def sign_in_as_user(options={}, &block)
    user = create_user(options)
    visit_with_option options[:visit], new_user_session_path
    fill_in 'email', with: options[:email] || 'user@test.com'
    fill_in 'password', with: options[:password] || '12345678'
    check 'remember me' if options[:remember_me] == true
    yield if block_given?
    click_button 'Log In'
    user
  end
end

RSpec.configure do |config|
  config.include RailsTestHelpers
end
