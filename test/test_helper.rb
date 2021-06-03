require "bundler/setup"
require "combustion"
Bundler.require(:default)
require "minitest/autorun"
require "minitest/pride"

Combustion.path = "test/internal"
Combustion.initialize! :active_record, :action_mailer

ActiveRecord::Base.logger = ActiveSupport::Logger.new(STDOUT) if ENV["VERBOSE"]
ActionMailer::Base.delivery_method = :test

class Minitest::Test
  def setup
    User.delete_all
    Mailkick::Subscription.delete_all
    Mailkick::OptOut.delete_all
  end
end
