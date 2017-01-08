require "bundler/setup"
Bundler.require(:default)
require "minitest/autorun"
require "minitest/pride"
require "logger"
require "action_mailer"

Minitest::Test = Minitest::Unit::TestCase unless defined?(Minitest::Test)
ActionMailer::Base.delivery_method = :test

Mailkick.secret_token = "test123"

class UserMailer < ActionMailer::Base
  default from: "from@example.com"

  def welcome
    mail to: "test@example.org", subject: "Hello", body: "Boom subscriptions/%7B%7BMAILKICK_TOKEN%7D%7D/unsubcribe"
  end
end
