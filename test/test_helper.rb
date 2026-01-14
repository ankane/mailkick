require "bundler/setup"
require "combustion"
Bundler.require(:default)
require "minitest/autorun"

Combustion.path = "test/internal"
Combustion.initialize! :active_record, :action_mailer do
  config.load_defaults Rails::VERSION::STRING.to_f
  config.secret_key_base = "0" * 128
end

ActiveRecord::Base.logger = ActiveSupport::Logger.new(STDOUT) if ENV["VERBOSE"]
ActionMailer::Base.delivery_method = :test

class Minitest::Test
  def setup
    User.delete_all
    Company.delete_all
    Mailkick::OptOut.delete_all
  end

  def with_headers
    previous_value = Mailkick.headers
    begin
      Mailkick.headers = true
      yield
    ensure
      Mailkick.headers = previous_value
    end
  end
end
