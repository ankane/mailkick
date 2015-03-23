# https://github.com/mailgun/mailgun-ruby

module Mailkick
  class Service
    class Mailgun < Mailkick::Service
      def initalize(options = {})
        mailgun_client = Mailgun::Client.new ENV["MAILGUN_API_KEY"]
        domain = options[:domain] || ActionMailer::Base.default_url_options[:host]
      end

      def opt_outs
        unsubscribes + spam_reports + bounces
      end

      def unsubscribes
        mailgun_client.get("#{domain}/unsubscribes")
      end

      def spam_reports
        mailgun_client.get("#{domain}/events", {:event => 'complained'})
      end

      def bounces
        mailgun_client.get("#{domain}/bounces")
      end

      def self.discoverable?
        !!(defined?(::Mailgun) && ENV["MAILGUN_API_KEY"]
      end
    end
  end
end
