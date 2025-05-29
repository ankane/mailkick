# https://github.com/ActiveCampaign/postmark-gem

module Mailkick
  class Service
    class Postmark < Mailkick::Service
      REASONS_MAP = {
        "SpamNotification" => "spam",
        "SpamComplaint" => "spam",
        "Unsubscribe" => "unsubscribe"
      }

      def initialize(api_key: nil)
        @client = ::Postmark::ApiClient.new(api_key || ENV["POSTMARK_API_KEY"])
      end

      def opt_outs
        bounces
      end

      def bounces
        fetch(@client.bounces)
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
