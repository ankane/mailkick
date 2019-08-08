# https://github.com/wildbit/postmark-gem

module Mailkick
  class Service
    class Postmark < Mailkick::Service
      def initialize(options = {})
        @client = Postmark::ApiClient.new(api_key: options[:api_key] || ENV["POSTMARK_API_KEY"])
      end

      def opt_outs(options = {})
        options[:unsubscribe_count] ||= 10
        options[:spam_count] ||= 10
        options[:bounce_count] ||= 10
        unsubscribes(count: options[:unsubscribe_count], offset: options[:offset]) + spam_reports(count: options[:spam_count], offset: options[:offset]) + bounces(count: options[:bounce_count], offset: options[:offset])
      end

      def unsubscribes(options = {})
        fetch(get_bounces(type: 'Unsubscribe', count: options[:count], offset: options[:offset]), "unsubscribe")
      end

      def spam_reports(options = {})
        fetch(get_bounces(type: 'SpamNotification', count: options[:count], offset: options[:offset]), "spam")
      end

      def bounces(options = {})
        fetch(get_bounces(count: options[:count], offset: options[:offset]), "bounce")
      end

      def get_bounces(options = {})
        options[:count] ||= 30
        options[:offset] ||= 0
        @client.get_bounces(count: options[:count], offset: options[:offset], type: options[:type])
      end

      def self.discoverable?
        !!(defined?(::Postmark) && ENV["POSTMARK_API_KEY"])
      end

      protected

      def fetch(response, reason)
        response.map do |record|
          {
            email: record["email"],
            time: ActiveSupport::TimeZone["UTC"].parse(record[:bounced_at]),
            reason: reason
          }
        end
      end
    end
  end
end