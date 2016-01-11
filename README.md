# Devise::MultiEmail [![Build Status](https://travis-ci.org/allenwq/devise-multi_email.svg?branch=master)](https://travis-ci.org/allenwq/devise-multi_email)

Let [devise](https://github.com/plataformatec/devise) support multilpe emails, it allows you to:
- Login with multiple emails
- Send confirmations to multiple emails
- Recover the password with any of the emails
- Validations for multiple emails 

`:multi_email_authenticatable`, `:multi_email_confirmable` and `:multi_email_validatable` are provided by devise-multi_email.

## Getting Started

Add this line to your application's Gemfile, devise-multi_email has been tested with devise 4.0 and rails 4.2:

```ruby
gem 'devise-multi_email'
```

Suppose you have already setup devise, your `User` model might look like this:

```ruby
class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable
end
```

In order to let your `User` support multiple emails, with `devise-multi_email` what you need to do is just:

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

Note that `:email` column should be moved from users table to the emails table, and a new `primary` boolean column should be added to the emails table (so that all the emails will be sent to the primary email, and `user.email` will give you the primary email address). Your emails table's migration should look like:
```ruby
create_table :emails do |t|
  t.integer :user_id
  t.string :email
  t.boolean :primary
 end
```

## Confirmable with multiple emails
Sending different confirmaitons to different emails is supported. What you need to do is:

Declare `devise :multi_email_confirmable` in your `User` model:
```ruby
class User < ActiveRecord::Base
  has_many :emails

  # You should not declare :confiramble and :multi_email_confirmable at the same time.
  devise :multi_email_authenticatable, :registerable, :multi_email_confirmable
end
```

Add `:confirmation_token`, `:confirmed_at` and `:confirmation_sent_at` to your emails table:
```ruby
create_table :emails do |t|
  t.integer :user_id
  t.string :email
  t.boolean :primary, default: false

  ## Confirmable
  t.string   :confirmation_token
  t.datetime :confirmed_at
  t.datetime :confirmation_sent_at
end
```

Then all the methods in devise confirmable are avalible in your `Email` model. You can do `Email#send_confirmation_instructions` for each of your email. And `User#send_confirmation_instructions` will be delegated to the primary email.

## Validatable with multiple emails
Declare `devise :multi_email_validatable` in the user model, then all the user emails will be validated:

```ruby
class User < ActiveRecord::Base
  has_many :emails

  # You should not declare :validatable and :multi_email_validatable at the same time.
  devise :multi_email_authenticatable, :registerable, :multi_email_validatable
end
```

## What's more

The gem works with all other devise modules just as normal, you don't need to add the `multi_email` prefix.
```ruby
  devise :multi_email_authenticatable, :multi_email_confirmable, :multi_email_validatable, :lockable, 
         :recoverable, :registerable, :rememberable, :timeoutable, :trackable
```

## Issues
You need to implement add/delete emails for a user as well as set/unset primary email.

You can do `email.send_confirmation_instructions` for every email, but you also need to handle this logic in some place(excpet for the primary email). e.g. After a new email was added by a user, you might want to provide some buttons to allow user to resend confirmation instrucitons for that email.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/devise-multi_email. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

