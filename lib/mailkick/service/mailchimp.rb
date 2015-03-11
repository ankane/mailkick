# https://github.com/amro/gibbon

module Mailkick
  class Service
    class Mailchimp < Mailkick::Service
      def initialize(options = {})
        @gibbon = ::Gibbon::API.new(options[:api_key] || ENV["MAILCHIMP_API_KEY"])
        @list_id = options[:list_id] || ENV["MAILCHIMP_LIST_ID"]
      end

      # TODO paginate
      def opt_outs
        unsubscribes + spam_reports
      end

      def unsubscribes
        fetch(@gibbon.lists.members(id: @list_id, status: "unsubscribed"), "unsubscribe")
      end

      def spam_reports
        fetch(@gibbon.lists.abuse_reports(id: @list_id), "spam")
      end

      def self.discoverable?
        !!(defined?(::Gibbon) && ENV["MAILCHIMP_API_KEY"] && ENV["MAILCHIMP_LIST_ID"])
      end

      protected

      def fetch(response, reason)
        response["data"].map do |record|
          {
            email: record["email"],
            time: ActiveSupport::TimeZone["UTC"].parse(record["timestamp_opt"] || record["date"]),
            reason: reason
          }
        end
      end
    end
  end
end
