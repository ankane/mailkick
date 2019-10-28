## 0.4.1

- Added Postmark support

## 0.4.0

- Fixed error with model methods and `email_key` option
- Fixed bug with `opted_out` scope
- Dropped support for Action Mailer 4.2

## 0.3.1

- Fixed `Secret should not be nil` error in Rails 5.2
- Gracefully handle missing email
- Added `user` option to `mailkick_unsubscribe_url`

## 0.3.0

- Improved performance
- Fixed `Subscription not found` for Rails 5.2
- Use `references` in migration
- Use `smtp_settings[:domain]` for Mailgun
- Dropped support for Action Mailer < 4.2

## 0.2.1

- Fixed errors with Rails 5+
- Fixed errors with the latest version of Gibbon

## 0.2.0

- Added support for Rails 5.1

## 0.1.6

- Fixed error with frozen strings

## 0.1.5

- Use `safely`
- Only discover services if not manually set
- Added `mount` option

## 0.1.4

- Use `Module#prepend` instead of `alias_method_chain`

## 0.1.3

- Fixed issue with double escaping tokens

## 0.1.2

- Added support for Mailgun

## 0.1.1

- Fixed tokens with `+` in them

## 0.1.0

- Fixed secret token for Rails 4.1

## 0.0.6

- Rails 3 fix

## 0.0.5

- Fixed bug with subscriptions page

## 0.0.4

- Added `email_key` option to `mailkick_user`

## 0.0.3

- Added support for multiple lists
- Changed `mailkick_user` method names - sorry early adopters :(

## 0.0.2

- Added Mailchimp service
- Fixed Mandrill service
- Added `uniq` to `subscribed` scope

## 0.0.1

- First release
