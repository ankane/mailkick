# https://github.com/wildbit/postmark-gem
# For bounce types documentation, see: https://postmarkapp.com/developer/api/bounce-api#bounce-types

module Mailkick
  class Service
    class Postmark < Mailkick::Service
      REASONS_MAP = {
        # Explicit user actions
        "SpamNotification" => "spam",
        "SpamComplaint" => "spam",
        "Unsubscribe" => "unsubscribe",
        "ManuallyDeactivated" => "unsubscribe",

        # Permanent delivery failures
        "HardBounce" => "bounce",      # Server unable to deliver (unknown user, mailbox not found)
        "BadEmailAddress" => "bounce", # Invalid email address
        "Blocked" => "bounce",         # ISP block due to content/blacklisting
        "DMARCPolicy" => "bounce",     # Rejected due to DMARC Policy - usually permanent
        "AddressChange" => "bounce"    # User has requested an address change
      }

      def initialize(options = {})
        @client = ::Postmark::ApiClient.new(options[:api_key] || ENV["POSTMARK_API_KEY"])
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
          next unless should_opt_out?(record[:type])

          {
            email: record[:email],
            time: ActiveSupport::TimeZone["UTC"].parse(record[:bounced_at]),
            reason: REASONS_MAP[record[:type]]
          }
        end.compact
      end

      private

      def should_opt_out?(bounce_type)
        REASONS_MAP.key?(bounce_type)
      end
    end
  end
end
