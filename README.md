# Devise::MultiEmail [![Build Status](https://travis-ci.org/allenwq/devise-multi_email.svg?branch=master)](https://travis-ci.org/allenwq/devise-multi_email) [![Coverage Status](https://coveralls.io/repos/allenwq/devise-multi_email/badge.svg?branch=master&service=github)](https://coveralls.io/github/allenwq/devise-multi_email?branch=master)

Letting [Devise](https://github.com/plataformatec/devise) support multiple emails, allows you to:
- Login with multiple emails
- Send confirmations to multiple emails
- Recover the password with any of the emails
- Validations for multiple emails

`:multi_email_authenticatable`, `:multi_email_confirmable` and `:multi_email_validatable` are provided by _devise-multi_email_.

## Getting Started

Add this line to your application's `Gemfile`, _devise-multi_email_ has been tested with Devise 4.0 and rails 4.2:

```ruby
gem 'devise-multi_email'
```

Suppose you have already setup Devise, your `User` model might look like this:

```ruby
class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable
end
```

In order to let your `User` support multiple emails, with _devise-multi_email_ what you need to do is just:

```ruby
class User < ActiveRecord::Base
  has_many :emails

  # Replace :database_authenticatable, with :multi_email_authenticatable
  devise :multi_email_authenticatable, :registerable
end

class Email < ActiveRecord::Base
  belongs_to :user
end
```

Note that the `:email` column should be moved from `users` table to the `emails` table, and a new `primary` boolean column should be added to the `emails` table (so that all the emails will be sent to the primary email, and `user.email` will give you the primary email address). Your `emails` table's migration should look like:

```ruby
create_table :emails do |t|
  t.integer :user_id
  t.string :email
  t.boolean :primary
 end
```

### Configure custom association names

You may not want to use the association `user.emails` or `email.users`. You can customize the name of the associations used. Add your custom configurations to an initializer file such as `config/initializers/devise-multi_email.rb`.

_Note: model classes are inferred from the associations._

```ruby
Devise::MultiEmail.configure do |config|
  # Default is :user for Email model
  config.parent_association_name = :team
  # Default is :emails for parent (e.g. User) model
  config.emails_association_name = :email_addresses
  # For backwards-compatibility, specify :primary_email_record
  # Default is :primary_email
  config.primary_email_method_name = :primary_email_record
end

# Example use of custom association names
team = Team.first
emails = team.email_addresses

email = EmailAddress.first
team = email.team
```

## Confirmable with multiple emails

Sending separate confirmations to each email is supported. What you need to do is:

Declare `devise :multi_email_confirmable` in your `User` model:

```ruby
class User < ActiveRecord::Base
  has_many :emails

  # You should not declare :confirmable and :multi_email_confirmable at the same time.
  devise :multi_email_authenticatable, :registerable, :multi_email_confirmable
end
```

Add `:confirmation_token`, `:confirmed_at` and `:confirmation_sent_at` to your `emails` table:

```ruby
create_table :emails do |t|
  t.integer :user_id
  t.string :email
  t.boolean :primary, default: false

  ## Confirmable
  t.string :unconfirmed_email
  t.string :confirmation_token
  t.datetime :confirmed_at
  t.datetime :confirmation_sent_at
end
```

Then all the methods in Devise confirmable are available in your `Email` model. You can do `email#send_confirmation_instructions` for each of your email. And `user#send_confirmation_instructions` will be delegated to the primary email.

## Validatable with multiple emails

Declare `devise :multi_email_validatable` in the `User` model, then all the user emails will be validated:

```ruby
class User < ActiveRecord::Base
  has_many :emails

  # You should not declare :validatable and :multi_email_validatable at the same time.
  devise :multi_email_authenticatable, :registerable, :multi_email_validatable
end
```

You can find the detailed configurations in the [rails 5 example app](https://github.com/allenwq/devise-multi_email/tree/master/examples/rails5_app).

## ActiveJob Integration

The [Devise README](https://github.com/plataformatec/devise#activejob-integration) describes how to use ActiveJob to deliver emails in the background. Normally you would place the following code in your `User` model, however when using _devise-multi_email_ you should place this in the `Email` model.

```ruby
# models/email.rb
def send_devise_notification(notification, *args)
  devise_mailer.send(notification, self, *args).deliver_later
end
```

## What's more

The gem works with all other Devise modules as expected -- you don't need to add the "multi_email" prefix.

```ruby
class User < ActiveRecord::Base
  devise :multi_email_authenticatable, :multi_email_confirmable, :multi_email_validatable, :lockable,
         :recoverable, :registerable, :rememberable, :timeoutable, :trackable
end
```

## Issues

You need to implement add/delete emails for a user as well as set/unset "primary" for each email.

You can do `email.send_confirmation_instructions` for each email individually, but you need to handle that logic in some place (except for the primary email, which is handled by Devise by default). e.g. After a new email was added by a user, you might want to provide some buttons in the view to allow users to resend confirmation instructions for that email.

## Wiki

[Migrating exiting user records](https://github.com/allenwq/devise-multi_email/wiki/Migrating-existing-user-records)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/devise-multi_email. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
