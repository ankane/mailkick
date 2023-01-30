# dependencies
require "active_support"

# stdlib
require "json"
require "set"

# modules
require_relative "mailkick/legacy"
require_relative "mailkick/model"
require_relative "mailkick/serializer"
require_relative "mailkick/service"
require_relative "mailkick/service/aws_ses"
require_relative "mailkick/service/mailchimp"
require_relative "mailkick/service/mailgun"
require_relative "mailkick/service/mandrill"
require_relative "mailkick/service/sendgrid"
require_relative "mailkick/service/sendgrid_v2"
require_relative "mailkick/service/postmark"
require_relative "mailkick/url_helper"
require_relative "mailkick/version"

# integrations
require_relative "mailkick/engine" if defined?(Rails)

module Mailkick
  mattr_accessor :services, :mount, :process_opt_outs_method
  mattr_reader :secret_token
  mattr_writer :message_verifier
  self.services = []
  self.mount = true
  self.process_opt_outs_method = ->(_) { raise "process_opt_outs_method not defined" }

  def self.fetch_opt_outs
    services.each(&:fetch_opt_outs)
  end

  def self.discover_services
    Service.subclasses.each do |service|
      services << service.new if service.discoverable?
    end
  end

  def self.secret_token=(token)
    @@secret_token = token
    @@message_verifier = nil
  end

  def self.message_verifier
    @@message_verifier ||= ActiveSupport::MessageVerifier.new(Mailkick.secret_token, serializer: Serializer)
  end

  def self.generate_token(subscriber, list)
    raise ArgumentError, "Missing subscriber" unless subscriber
    raise ArgumentError, "Missing list" unless list.present?

    message_verifier.generate([nil, subscriber.id, subscriber.class.name, list])
  end
end

ActiveSupport.on_load(:action_mailer) do
  helper Mailkick::UrlHelper
end

ActiveSupport.on_load(:active_record) do
  extend Mailkick::Model
end
