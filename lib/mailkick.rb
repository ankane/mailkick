require "set"
require "active_support"

require "mailkick/engine" if defined?(Rails)
require "mailkick/model"
require "mailkick/service"
require "mailkick/service/mailchimp"
require "mailkick/service/mailgun"
require "mailkick/service/mandrill"
require "mailkick/service/sendgrid"
require "mailkick/version"

module Mailkick
  mattr_accessor :services, :user_method, :secret_token, :mount
  self.services = []
  self.user_method = ->(email) { User.where(email: email).first rescue nil }
  self.mount = true

  def self.fetch_opt_outs
    services.each(&:fetch_opt_outs)
  end

  def self.discover_services
    Service.subclasses.each do |service|
      services << service.new if service.discoverable?
    end
  end

  def self.opted_out?(options)
    opt_outs(options).any?
  end

  def self.opt_out(options)
    unless opted_out?(options)
      time = options[:time] || Time.now
      Mailkick::OptOut.create! do |o|
        o.email = options[:email]
        o.user = options[:user]
        o.reason = options[:reason] || "unsubscribe"
        o.list = options[:list]
        o.created_at = time
        o.updated_at = time
      end
    end
    true
  end

  def self.opt_in(options)
    opt_outs(options).each do |opt_out|
      opt_out.active = false
      opt_out.save!
    end
    true
  end

  def self.opt_outs(options = {})
    relation = Mailkick::OptOut.where(active: true)

    parts = []
    binds = []
    if (email = options[:email])
      parts << "email = ?"
      binds << email
    end
    if (user = options[:user])
      parts << "(user_id = ? and user_type = ?)"
      binds.concat [user.id, user.class.name]
    end
    relation = relation.where(parts.join(" OR "), *binds) if parts.any?

    relation =
      if options[:list]
        relation.where("list IS NULL OR list = ?", options[:list])
      else
        relation.where("list IS NULL")
      end

    relation
  end

  def self.opted_out_emails(options = {})
    Set.new(opt_outs(options).where("email IS NOT NULL").uniq.pluck(:email))
  end

  # does not take into account emails
  def self.opted_out_users(options = {})
    Set.new(opt_outs(options).where("user_id IS NOT NULL").map(&:user))
  end

  def self.message_verifier
    @message_verifier ||= ActiveSupport::MessageVerifier.new(Mailkick.secret_token)
  end

  def self.generate_token(email, list: nil)
    user = Mailkick.user_method.call(email) if Mailkick.user_method
    message_verifier.generate([email, user.try(:id), user.try(:class).try(:name), list])
  end
end

ActiveSupport.on_load(:active_record) do
  extend Mailkick::Model
end
