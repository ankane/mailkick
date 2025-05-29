# https://github.com/amro/gibbon

module Mailkick
  class Service
    class Mailchimp < Mailkick::Service
      def initialize(api_key: nil, list_id: nil)
        @gibbon = ::Gibbon::Request.new(api_key: api_key || ENV["MAILCHIMP_API_KEY"])
        @list_id = list_id || ENV["MAILCHIMP_LIST_ID"]
      end

      # TODO paginate
      def opt_outs
        unsubscribes + spam_reports
      end

      def unsubscribes
        fetch(@gibbon.lists(@list_id).members.retrieve(params: {status: "unsubscribed"}).body["members"], "unsubscribe")
      end

      def spam_reports
        fetch(@gibbon.lists(@list_id).abuse_reports.retrieve.body["abuse_reports"], "spam")
      end

      def self.discoverable?
        !!(defined?(::Gibbon) && ENV["MAILCHIMP_API_KEY"] && ENV["MAILCHIMP_LIST_ID"])
      end

      protected

      def fetch(response, reason)
        response.map do |record|
          {
            email: record["email_address"],
            time: ActiveSupport::TimeZone["UTC"].parse(record["timestamp_opt"] || record["date"]),
            reason: reason
          }
        end
      end
    end
  end
end
