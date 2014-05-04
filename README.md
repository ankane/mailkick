# Mailkick

:bullettrain_side: Email subscriptions made easy

- Add one-click unsubscribe links to your emails
- Fetch bounces and spam reports from your email service

Gracefully handles email address changes

:postbox: Check out [Ahoy Email](https://github.com/ankane/ahoy_email) for analytics

## Installation

Add this line to your application’s Gemfile:

```ruby
gem 'mailkick'
```

And run the generator. This creates a model to store opt-outs.

```sh
rails generate mailkick:install
rake db:migrate
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

Add the following the method to your user model.

```ruby
class User < ActiveRecord::Base
  mailkick_user
end
```

Get all users who have not unsubscribed

```ruby
User.subscribed
```

Check one user

```ruby
user.subscribed?
```

Unsubscribe

```ruby
user.unsubscribe
```

Subscribe

```ruby
user.subscribe
```

## Bounces and Spam Reports

Pull bounces, spam reports, and unsubscribes from your email service.

```ruby
Mailkick.fetch_opt_outs
```

#### Sendgrid

Add the gem

```ruby
gem 'sendgrid_toolkit'
```

Be sure `ENV["SENDGRID_USERNAME"]` and `ENV["SENDGRID_PASSWORD"]` are set.

#### Mandrill [broken]

```ruby
gem 'mandrill-api'
```

Be sure `ENV["MANDRILL_APIKEY"]` is set.

#### Mailchimp [master]

```ruby
gem 'gibbon'
```

Be sure `ENV["MAILCHIMP_API_KEY"]` and `ENV["MAILCHIMP_LIST_ID"]` are set.

#### Other

Will gladly accept pull requests.

### Advanced

For more control over the services, set them by hand.

```ruby
Mailkick.services = [
  Mailkick::Service::Sendgrid.new(api_key: "API_KEY"),
  Mailkick::Service::Mandrill.new(api_key: "API_KEY")
]
```

## Multiple Lists

Coming soon

## Bonus

More great gems for email

- [Roadie](https://github.com/Mange/roadie) - inline CSS
- [Letter Opener](https://github.com/ryanb/letter_opener) - preview email in development

## Reference

Change how the user is determined

```ruby
Mailkick.user_method = proc {|email| User.where(email: email).first }
```

## History

View the [changelog](https://github.com/ankane/mailkick/blob/master/CHANGELOG.md)

## Contributing

Everyone is encouraged to help improve this project. Here are a few ways you can help:

- [Report bugs](https://github.com/ankane/mailkick/issues)
- Fix bugs and [submit pull requests](https://github.com/ankane/mailkick/pulls)
- Write, clarify, or fix documentation
- Suggest or add new features
