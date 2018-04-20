# Mailkick

:bullettrain_side: Email subscriptions made easy

- Add one-click unsubscribe links to your emails
- Fetch bounces and spam reports from your email service
- Gracefully handles email address changes

:postbox: Check out [Ahoy Email](https://github.com/ankane/ahoy_email) for analytics

[![Build Status](https://travis-ci.org/ankane/mailkick.svg?branch=master)](https://travis-ci.org/ankane/mailkick)

## Installation

Add this line to your application’s Gemfile:

```ruby
gem 'mailkick'
```

And run the generator. This creates a model to store opt-outs.

```sh
rails generate mailkick:install
rails db:migrate
```

## How It Works

Add an unsubscribe link to your emails.

#### Text

```erb
Unsubscribe: <%= mailkick_unsubscribe_url %>
```

#### HTML

```erb
<%= link_to "Unsubscribe", mailkick_unsubscribe_url %>
```

When a user unsubscribes, he or she is taken to a mobile-friendly page and given the option to resubscribe.

To customize the view, run:

```sh
rails generate mailkick:views
```

which copies the view into `app/views/mailkick`.

## Sending Emails

Before sending marketing emails, make sure the user has not opted out.

Add the following method to models with email addresses.

```ruby
class User < ApplicationRecord
  mailkick_user
end
```

Get all users who have opted out

```ruby
User.opted_out
```

And those who have not - send to these people

```ruby
User.not_opted_out
```

Check one user

```ruby
user.opted_out?
```

## Bounces and Spam Reports

Fetch bounces, spam reports, and unsubscribes from your email service.

```ruby
Mailkick.fetch_opt_outs
```

#### Sendgrid

Add the gem

```ruby
gem 'sendgrid_toolkit'
```

Be sure `ENV["SENDGRID_USERNAME"]` and `ENV["SENDGRID_PASSWORD"]` are set.

#### Mandrill

```ruby
gem 'mandrill-api'
```

Be sure `ENV["MANDRILL_APIKEY"]` is set.

#### Mailchimp

```ruby
gem 'gibbon', '>= 2'
```

Be sure `ENV["MAILCHIMP_API_KEY"]` and `ENV["MAILCHIMP_LIST_ID"]` are set.

#### Mailgun

```ruby
gem 'mailgun-ruby'
```

Be sure `ENV["MAILGUN_API_KEY"]` is set.

#### Other

Will gladly accept pull requests.

### Advanced

For more control over services, set them by hand.

```ruby
Mailkick.services = [
  Mailkick::Service::Sendgrid.new(api_key: "API_KEY"),
  Mailkick::Service::Mandrill.new(api_key: "API_KEY")
]
```

## Multiple Lists [beta]

You may want to split your emails into multiple categories, like sale emails and order reminders.

Set the list in the mailer.

```ruby
class UserMailer < ApplicationMailer
  def order_reminder(user)
    headers[:mailkick_list] = "order_reminders"
    # ...
  end
end
```

Pass the `list` option to methods.

```ruby
User.opted_out(list: "order_reminders")
User.not_opted_out(list: "order_reminders")
user.opted_out?(list: "order_reminders")
```

### Opt-In Lists

For opt-in lists, you’ll need to manage the subscribers yourself.

Check opt-ins against the opt-outs

```ruby
User.where(send_me_sales: true).not_opted_out(list: "sales")
```

Check one user

```ruby
user.send_me_sales && !user.opted_out?(list: "sales")
```

## Bonus

More great gems for email

- [Roadie](https://github.com/Mange/roadie) - inline CSS
- [Letter Opener](https://github.com/ryanb/letter_opener) - preview email in development

## TODO

- Make it easy to customize controller
- Subscribe to events

## Reference

Change how the user is determined

```ruby
Mailkick.user_method = ->(email) { User.find_by(email: email) }
```

Use a different email field

```ruby
mailkick_user email_key: :email_address
```

Unsubscribe

```ruby
user.opt_out
```

Resubscribe

```ruby
user.opt_in
```

## History

View the [changelog](https://github.com/ankane/mailkick/blob/master/CHANGELOG.md)

## Contributing

Everyone is encouraged to help improve this project. Here are a few ways you can help:

- [Report bugs](https://github.com/ankane/mailkick/issues)
- Fix bugs and [submit pull requests](https://github.com/ankane/mailkick/pulls)
- Write, clarify, or fix documentation
- Suggest or add new features
