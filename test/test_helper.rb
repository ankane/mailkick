require "bundler/setup"
require "combustion"
Bundler.require(:default)
require "minitest/autorun"
require "minitest/pride"

Combustion.path = "test/internal"
Combustion.initialize! :active_record, :action_mailer

ActiveRecord::Base.logger = ActiveSupport::Logger.new(STDOUT) if ENV["VERBOSE"]
ActionMailer::Base.delivery_method = :test
