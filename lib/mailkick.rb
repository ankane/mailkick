# dependencies
require "active_support"

# stdlib
require "json"
require "set"

# modules
require_relative "mailkick/model"
require_relative "mailkick/service"
require_relative "mailkick/service/aws_ses"
require_relative "mailkick/service/mailchimp"
require_relative "mailkick/service/mailgun"
require_relative "mailkick/service/mandrill"
require_relative "mailkick/service/sendgrid"
require_relative "mailkick/service/postmark"
require_relative "mailkick/url_helper"
require_relative "mailkick/version"

# integrations
require_relative "mailkick/engine" if defined?(Rails)

module Mailkick
  mattr_accessor :services, :mount, :process_opt_outs_method, :headers
  mattr_reader :secret_token
  mattr_writer :message_verifier
  self.services = []
  self.mount = true
  self.process_opt_outs_method = ->(_) { raise "process_opt_outs_method not defined" }
  self.headers = false

  class << self
    # Check if an email has opted out for a specific company and list
    #
    # @param email [String] the email address to check
    # @param company_id [Integer] the company ID to scope the check
    # @param list [String] the mailing list (default: "marketing")
    # @return [Boolean] true if opted out, false otherwise
    def opted_out?(email:, company_id:, list: "marketing")
      raise ArgumentError, "Missing email" unless email.present?
      raise ArgumentError, "Missing company_id" unless company_id.present?

      Mailkick::OptOut
        .for_email(email)
        .for_company(company_id)
        .for_list(list)
        .exists?
    end

    # Record an opt-out for an email address
    #
    # @param email [String] the email address opting out
    # @param company_id [Integer] the company ID to scope the opt-out
    # @param list [String] the mailing list (default: "marketing")
    # @return [Mailkick::OptOut] the created opt-out record
    def opt_out(email:, company_id:, list: "marketing")
      raise ArgumentError, "Missing email" unless email.present?
      raise ArgumentError, "Missing company_id" unless company_id.present?

      Mailkick::OptOut.find_or_create_by!(
        email: email.to_s.downcase.strip,
        company_id: company_id,
        list: list
      )
    end

    # Remove an opt-out for an email address (re-subscribe)
    #
    # @param email [String] the email address opting back in
    # @param company_id [Integer] the company ID to scope the opt-in
    # @param list [String] the mailing list (default: "marketing")
    # @return [Integer] number of records deleted
    def opt_in(email:, company_id:, list: "marketing")
      raise ArgumentError, "Missing email" unless email.present?
      raise ArgumentError, "Missing company_id" unless company_id.present?

      Mailkick::OptOut
        .for_email(email)
        .for_company(company_id)
        .for_list(list)
        .delete_all
    end

    # Get all opt-outs for a company
    #
    # @param company_id [Integer] the company ID
    # @param list [String, nil] optional mailing list filter
    # @return [ActiveRecord::Relation] opt-out records
    def opt_outs_for_company(company_id:, list: nil)
      scope = Mailkick::OptOut.for_company(company_id)
      scope = scope.for_list(list) if list.present?
      scope
    end

    # Get all opt-outs for an email address across all companies
    #
    # @param email [String] the email address
    # @return [ActiveRecord::Relation] opt-out records
    def opt_outs_for_email(email:)
      Mailkick::OptOut.for_email(email)
    end
  end

  def self.fetch_opt_outs
    services.each(&:fetch_opt_outs)
    nil
  end

  def self.discover_services
    Service.subclasses.each do |service|
      services << service.new if service.discoverable?
    end
    nil
  end

  def self.secret_token=(token)
    @@secret_token = token
    @@message_verifier = nil
  end

  def self.message_verifier
    @@message_verifier ||= ActiveSupport::MessageVerifier.new(Mailkick.secret_token, serializer: JSON)
  end

  # Generate a secure token for unsubscribe URLs
  #
  # @param email [String] the email address
  # @param company_id [Integer] the company ID
  # @param list [String] the mailing list (default: "marketing")
  # @return [String] the encoded token
  def self.generate_token(email, company_id, list = "marketing")
    raise ArgumentError, "Missing email" unless email.present?
    raise ArgumentError, "Missing company_id" unless company_id.present?
    raise ArgumentError, "Missing list" unless list.present?

    message_verifier.generate([email.to_s.downcase.strip, company_id, list])
  end

  # Verify and decode a token
  #
  # @param token [String] the encoded token
  # @return [Array] [email, company_id, list]
  def self.verify_token(token)
    message_verifier.verify(token)
  end
end

ActiveSupport.on_load(:action_mailer) do
  helper Mailkick::UrlHelper
end

ActiveSupport.on_load(:active_record) do
  extend Mailkick::Model
end
