require "bundler/setup"
Bundler.require(:default)
require "minitest/autorun"
require "minitest/pride"
require "logger"
require "combustion"

Minitest::Test = Minitest::Unit::TestCase unless defined?(Minitest::Test)

Combustion.path = "test/internal"
Combustion.initialize! :all do
  if config.active_record.sqlite3.respond_to?(:represent_boolean_as_integer)
    config.active_record.sqlite3.represent_boolean_as_integer = true
  end
end

ActionMailer::Base.delivery_method = :test

Mailkick.secret_token = "test123"

class UserMailer < ActionMailer::Base
  default from: "from@example.com"

  def welcome
    mail to: "test@example.org", subject: "Hello" do |format|
      format.html { render plain: "<p>%7B%7BMAILKICK_TOKEN%7D%7D</p>" }
      format.text { render plain: "Boom: %7B%7BMAILKICK_TOKEN%7D%7D" }
    end
  end
end
