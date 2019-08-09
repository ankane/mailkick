# https://github.com/wildbit/postmark-gem

module Mailkick
  class Service
    class Postmark < Mailkick::Service
      REASONS_MAP = {
        "SpamNotification" => "spam",
        "SpamComplaint" => "spam",
        "Unsubscribe" => "unsubscribe",
      }

      def initialize(options = {})
        @client = ::Postmark::ApiClient.new(options[:api_key] || ENV["POSTMARK_API_KEY"])
      end

      def opt_outs(options = {})
        bounces(count: options[:bounce_count], offset: options[:offset])
      end

      def bounces(options = {})
        fetch(@client.get_bounces(count: options[:count], offset: options[:offset]))
      end

      def self.discoverable?
        !!(defined?(::Postmark) && ENV["POSTMARK_API_KEY"])
      end

      protected

      def fetch(response)
        response.map do |record|
          {
            email: record[:email],
            time: ActiveSupport::TimeZone["UTC"].parse(record[:bounced_at]),
            reason: REASONS_MAP.fetch(record[:type], "bounce")
          }
        end
      end
    end
  end
end