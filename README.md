# Mailkick

Email subscriptions for Rails

- Add one-click unsubscribe links and headers to your emails
- Fetch bounces and spam reports from your email service

:postbox: Check out [Ahoy Email](https://github.com/ankane/ahoy_email) for analytics

[![Build Status](https://github.com/ankane/mailkick/actions/workflows/build.yml/badge.svg)](https://github.com/ankane/mailkick/actions)

## Installation

Add this line to your application’s Gemfile:

```ruby
gem "mailkick"
```

And run the generator. This creates a table to store subscriptions.

```sh
bundle install
rails generate mailkick:install
rails db:migrate
```

## Getting Started

Add `has_subscriptions` to your user model:

```ruby
class User < ApplicationRecord
  has_subscriptions
end
```

Subscribe to a list

```ruby
user.mailkick_subscribe("sales")
# or if no conflict with existing methods
user.subscribe("sales")
```

Unsubscribe from a list

```ruby
user.mailkick_unsubscribe("sales")
# or if no conflict with existing methods
user.unsubscribe("sales")
```

Check if subscribed

```ruby
user.mailkick_subscribed?("sales")
# or if no conflict with existing methods
user.subscribed?("sales")
```

Get subscribers for a list (use this for sending emails)

```ruby
User.mailkick_subscribed("sales")
# or if no conflict with existing methods
User.subscribed("sales")
```

### Method Naming

All Mailkick methods are available with the `mailkick_` prefix to avoid conflicts with existing methods in your models. If your model doesn't have methods with the same names, Mailkick will also create shorter aliases for convenience:

- `mailkick_subscribe` → `subscribe`
- `mailkick_unsubscribe` → `unsubscribe`
- `mailkick_subscribed?` → `subscribed?`
- `mailkick_subscriptions` → `subscriptions`

## Unsubscribe Links

Add an unsubscribe link to your emails. For HTML emails, use:

```erb
<%= link_to "Unsubscribe", mailkick_unsubscribe_url(@user, "sales") %>
```

For text emails, use:

```erb
Unsubscribe: <%= mailkick_unsubscribe_url(@user, "sales") %>
```

When a user unsubscribes, they are taken to a mobile-friendly page and given the option to resubscribe. To customize the view, run:

```sh
rails generate mailkick:views
```

which copies the view into `app/views/mailkick`.

## Unsubscribe Headers

For one-click unsubscribe headers ([RFC 8058](https://datatracker.ietf.org/doc/html/rfc8058)), create `config/initializers/mailkick.rb` with:

```ruby
Mailkick.headers = true
```

Headers will automatically be added to emails that call `mailkick_unsubscribe_url`.

## Bounces and Spam Reports

Fetch bounces, spam reports, and unsubscribes from your email service. Create `config/initializers/mailkick.rb` with a method to handle opt outs.

```ruby
Mailkick.process_opt_outs_method = lambda do |opt_outs|
  emails = opt_outs.map { |v| v[:email] }
  subscribers = User.includes(:mailkick_subscriptions).where(email: emails).index_by(&:email)

  opt_outs.each do |opt_out|
    subscriber = subscribers[opt_out[:email]]
    next unless subscriber

    subscriber.mailkick_subscriptions.each do |subscription|
      subscription.destroy if subscription.created_at < opt_out[:time]
    end
  end
end
```

And run:

```ruby
Mailkick.fetch_opt_outs
```

The following services are supported:

- [AWS SES](#aws-ses)
- [Mailchimp](#mailchimp)
- [Mailgun](#mailgun)
- [Mandrill](#mandrill)
- [Postmark](#postmark)
- [SendGrid](#sendgrid)

#### AWS SES

Add the gem

```ruby
gem "aws-sdk-sesv2"
```

And [configure your AWS credentials](https://github.com/aws/aws-sdk-ruby#configuration). Requires `ses:ListSuppressedDestinations` permission.

If you started using Amazon SES [before November 25, 2019](https://docs.aws.amazon.com/ses/latest/DeveloperGuide/sending-email-suppression-list.html#sending-email-suppression-list-considerations), you have to manually [enable account-level suppression list feature](https://docs.aws.amazon.com/ses/latest/APIReference-V2/API_PutAccountSuppressionAttributes.html).

#### Mailchimp

Add the gem

```ruby
gem "gibbon", ">= 2"
```

And set `ENV["MAILCHIMP_API_KEY"]` and `ENV["MAILCHIMP_LIST_ID"]`.

#### Mailgun

Add the gem

```ruby
gem "mailgun-ruby"
```

And set `ENV["MAILGUN_API_KEY"]`.

#### Mandrill

Add the gem

```ruby
gem "mandrill-api"
```

And set `ENV["MANDRILL_API_KEY"]`.

#### Postmark

Add the gem

```ruby
gem "postmark"
```

And set `ENV["POSTMARK_API_KEY"]`.

#### SendGrid

Add the gem

```ruby
gem "sendgrid-ruby"
```

And set `ENV["SENDGRID_API_KEY"]`. The API key requires only the `Suppressions` permission.

### Advanced

For more control over services, set them by hand.

```ruby
Mailkick.services = [
  Mailkick::Service::SendGridV2.new(api_key: "API_KEY"),
  Mailkick::Service::Mailchimp.new(api_key: "API_KEY", list_id: "LIST_ID")
]
```

## Reference

Access the subscription model directly

```ruby
Mailkick::Subscription.all
```

## History

View the [changelog](https://github.com/ankane/mailkick/blob/master/CHANGELOG.md)

## Contributing

Everyone is encouraged to help improve this project. Here are a few ways you can help:

- [Report bugs](https://github.com/ankane/mailkick/issues)
- Fix bugs and [submit pull requests](https://github.com/ankane/mailkick/pulls)
- Write, clarify, or fix documentation
- Suggest or add new features

To get started with development and testing:

```sh
git clone https://github.com/ankane/mailkick.git
cd mailkick
bundle install
bundle exec rake test
```
