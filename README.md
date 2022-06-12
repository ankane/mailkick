# Mailkick

Email subscriptions for Rails

- Add one-click unsubscribe links to your emails
- Fetch bounces and spam reports from your email service

:postbox: Check out [Ahoy Email](https://github.com/ankane/ahoy_email) for analytics

[![Build Status](https://github.com/ankane/mailkick/workflows/build/badge.svg?branch=master)](https://github.com/ankane/mailkick/actions)

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
user.subscribe("sales")
```

Unsubscribe from a list

```ruby
user.unsubscribe("sales")
```

Check if subscribed

```ruby
user.subscribed?("sales")
```

Get subscribers for a list (use this for sending emails)

```ruby
User.subscribed("sales")
```

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

Will gladly accept pull requests for others.

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

And set `ENV["MANDRILL_APIKEY"]`.

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

## Upgrading

### 1.0

Mailkick 1.0 stores subscriptions instead of opt-outs. To migrate:

1. Add a table to store subscriptions

```sh
rails generate mailkick:install
rails db:migrate
```

2. Change the following methods in your code:

- `mailkick_user` to `has_subscriptions`
- `User.not_opted_out` to `User.subscribed(list)`
- `opt_in` to `subscribe(list)`
- `opt_out` to `unsubscribe(list)`

3. Add a user and list to `mailkick_unsubscribe_url`

```ruby
mailkick_unsubscribe_url(user, list)
```

4. Migrate data for each of your lists

```ruby
opted_out_emails = Mailkick::Legacy.opted_out_emails(list: nil)
opted_out_users = Mailkick::Legacy.opted_out_users(list: nil)

User.find_in_batches do |users|
  users.reject! { |u| opted_out_emails.include?(u.email) }
  users.reject! { |u| opted_out_users.include?(u) }

  now = Time.now
  records =
    users.map do |user|
      {
        subscriber_type: user.class.name,
        subscriber_id: user.id,
        list: "sales",
        created_at: now,
        updated_at: now
      }
    end

  # use create! for Active Record < 6
  Mailkick::Subscription.insert_all!(records)
end
```

5. Drop the `mailkick_opt_outs` table

```ruby
drop_table :mailkick_opt_outs
```

Also, if you use `Mailkick.fetch_opt_outs`, [add a method](#bounces-and-spam-reports) to handle opt outs.

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
