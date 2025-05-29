# https://github.com/ActiveCampaign/postmark-gem

module Mailkick
  class Service
    class Postmark < Mailkick::Service
      REASONS_MAP = {
        "HardBounce" => "bounce",
        "SpamComplaint" => "spam",
        "ManualSuppression" => "unsubscribe"
      }

      def initialize(api_key: nil, stream_id: "outbound")
        @client = ::Postmark::ApiClient.new(api_key || ENV["POSTMARK_API_KEY"])
        @stream_id = stream_id
      end

      def opt_outs
        suppressions
      end

      def suppressions
        fetch(@client.dump_suppressions(@stream_id))
      end

      def self.discoverable?
        !!(defined?(::Postmark) && ENV["POSTMARK_API_KEY"])
      end

      protected

      def fetch(response)
        response.map do |record|
          {
            email: record[:email_address],
            time: ActiveSupport::TimeZone["UTC"].parse(record[:created_at]),
            reason: REASONS_MAP[record[:suppression_reason]]
          }
        end
      end
    end
  end
end
