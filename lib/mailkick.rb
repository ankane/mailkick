# dependencies
require "active_support"

# stdlib
require "set"

# modules
require "mailkick/legacy"
require "mailkick/model"
require "mailkick/service"
require "mailkick/service/aws_ses"
require "mailkick/service/mailchimp"
require "mailkick/service/mailgun"
require "mailkick/service/mandrill"
require "mailkick/service/sendgrid"
require "mailkick/service/sendgrid_v2"
require "mailkick/service/postmark"
require "mailkick/url_helper"
require "mailkick/version"

# integrations
require "mailkick/engine" if defined?(Rails)

module Mailkick
  mattr_accessor :services, :secret_token, :mount, :process_opt_outs_method
  self.services = []
  self.mount = true
  self.process_opt_outs_method = -> { raise "process_opt_outs_method not defined" }

  def self.fetch_opt_outs
    services.each(&:fetch_opt_outs)
  end

  def self.discover_services
    Service.subclasses.each do |service|
      services << service.new if service.discoverable?
    end
  end

  def self.message_verifier
    @message_verifier ||= ActiveSupport::MessageVerifier.new(Mailkick.secret_token)
  end

  def self.generate_token(subscriber, list)
    raise ArgumentError, "Missing subscriber" unless subscriber
    raise ArgumentError, "Missing list" unless list.present?

    message_verifier.generate([nil, subscriber.id, subscriber.class.name, list])
  end
end

ActiveSupport.on_load :action_mailer do
  helper Mailkick::UrlHelper
end

ActiveSupport.on_load(:active_record) do
  extend Mailkick::Model
end
