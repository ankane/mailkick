require "mailkick/version"
require "mailkick/engine"
require "mailkick/processor"
require "mailkick/mailer"
require "mailkick/model"
require "mailkick/service"
require "mailkick/service/mailchimp"
require "mailkick/service/mandrill"
require "mailkick/service/sendgrid"

module Mailkick
  mattr_accessor :services, :user_method, :secret_token
  self.services = []
  self.user_method = proc{|email| User.where(email: email).first rescue nil }

  def self.fetch_opt_outs
    services.each do |service|
      service.fetch_opt_outs
    end
  end

  def self.discover_services
    Service.subclasses.each do |service|
      if service.discoverable?
        services << service.new
      end
    end
  end

end

ActionMailer::Base.send :include, Mailkick::Mailer
ActiveRecord::Base.send(:extend, Mailkick::Model) if defined?(ActiveRecord)
