# Mailkick

Multi-tenant email opt-out management for Rails

- Track email opt-outs scoped by email address and company
- Add one-click unsubscribe links and headers to your emails
- CAN-SPAM compliant unsubscribe mechanism
- Support for multiple mailing lists (e.g., marketing, transactional)

:postbox: Check out [Ahoy Email](https://github.com/ankane/ahoy_email) for analytics

[![Build Status](https://github.com/ankane/mailkick/actions/workflows/build.yml/badge.svg)](https://github.com/ankane/mailkick/actions)

## Installation

Add this line to your application's Gemfile:

```ruby
gem "mailkick"
```

And run the generator. This creates a table to store opt-outs.

```sh
bundle install
rails generate mailkick:install
rails db:migrate
```

## Getting Started

### Opt-out Tracking

Mailkick uses an **opt-out model** - users are subscribed by default and only tracked when they opt out. This is ideal for CAN-SPAM compliance.

Check if an email has opted out:

```ruby
Mailkick.opted_out?(email: "user@example.com", company_id: 123, list: "marketing")
```

Record an opt-out:

```ruby
Mailkick.opt_out(email: "user@example.com", company_id: 123, list: "marketing")
```

Remove an opt-out (re-subscribe):

```ruby
Mailkick.opt_in(email: "user@example.com", company_id: 123, list: "marketing")
```

### Multi-tenant Scoping

Opt-outs are scoped by **company_id**, ensuring that opting out from Company A's emails doesn't affect Company B's emails.

```ruby
# User opts out from Company A's marketing emails
Mailkick.opt_out(email: "user@example.com", company_id: company_a.id, list: "marketing")

# Still subscribed to Company B's marketing emails
Mailkick.opted_out?(email: "user@example.com", company_id: company_b.id, list: "marketing")
# => false
```

### Mailing Lists

You can scope opt-outs by list type (default is "marketing"):

```ruby
# Opt out of marketing emails
Mailkick.opt_out(email: "user@example.com", company_id: 123, list: "marketing")

# Still subscribed to transactional emails
Mailkick.opted_out?(email: "user@example.com", company_id: 123, list: "transactional")
# => false
```

## Unsubscribe Links

Add an unsubscribe link to your emails. For HTML emails, use:

```erb
<%= link_to "Unsubscribe", mailkick_unsubscribe_url(@recipient_email, @company_id, "marketing") %>
```

For text emails, use:

```erb
Unsubscribe: <%= mailkick_unsubscribe_url(@recipient_email, @company_id, "marketing") %>
```

When a user clicks the link, they are taken to a mobile-friendly page showing their current subscription status and the option to unsubscribe or resubscribe.

To customize the view, run:

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

## Model Convenience Methods (Optional)

You can add convenience methods to your models:

```ruby
class User < ApplicationRecord
  has_email_opt_outs email_field: :email
end
```

Then use:

```ruby
user.opted_out_of?(company_id: 123, list: "marketing")
user.opt_out_of(company_id: 123, list: "marketing")
user.opt_in_to(company_id: 123, list: "marketing")
```

## Querying Opt-outs

Get all opt-outs for a company:

```ruby
Mailkick.opt_outs_for_company(company_id: 123)
Mailkick.opt_outs_for_company(company_id: 123, list: "marketing")
```

Get all opt-outs for an email across all companies:

```ruby
Mailkick.opt_outs_for_email(email: "user@example.com")
```

Access the opt-out model directly:

```ruby
Mailkick::OptOut.all
Mailkick::OptOut.for_email("user@example.com")
Mailkick::OptOut.for_company(123)
Mailkick::OptOut.for_list("marketing")
```

## Checking Opt-outs Before Sending

Create a mail interceptor to check opt-outs before sending marketing emails:

```ruby
# config/initializers/mail_interceptors.rb
class CheckOptOuts
  def self.delivering_email(message)
    # Only check marketing emails
    return unless message[:X-Email-Category]&.value == "marketing"

    company_id = message[:X-Company-Id]&.value&.to_i
    return unless company_id

    message.to.each do |email|
      if Mailkick.opted_out?(email: email, company_id: company_id, list: "marketing")
        message.perform_deliveries = false
        Rails.logger.info "Blocked email to #{email} - opted out"
        break
      end
    end
  end
end

ActionMailer::Base.register_interceptor(CheckOptOuts)
```

## Bounces and Spam Reports

Fetch bounces, spam reports, and unsubscribes from your email service. Create `config/initializers/mailkick.rb` with a method to handle opt outs.

```ruby
Mailkick.process_opt_outs_method = lambda do |opt_outs|
  opt_outs.each do |opt_out|
    # Opt out the email from all companies for marketing emails
    # Customize this based on your needs
    Company.find_each do |company|
      Mailkick.opt_out(
        email: opt_out[:email],
        company_id: company.id,
        list: "marketing"
      )
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
  Mailkick::Service::SendGrid.new(api_key: "API_KEY"),
  Mailkick::Service::Mailchimp.new(api_key: "API_KEY", list_id: "LIST_ID")
]
```

## Token Generation

Mailkick uses secure tokens for unsubscribe URLs. Tokens encode the email, company_id, and list, and are verified using Rails' MessageVerifier.

Generate a token manually:

```ruby
token = Mailkick.generate_token("user@example.com", 123, "marketing")
```

Verify a token:

```ruby
email, company_id, list = Mailkick.verify_token(token)
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
