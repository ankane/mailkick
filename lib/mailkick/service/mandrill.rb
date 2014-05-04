# https://mandrillapp.com/api/docs/index.ruby.html

module Mailkick
  class Service
    class Mandrill < Mailkick::Service

      def initialize(options = {})
        require "mandrill"
        @mandrill = ::Mandrill::API.new(options[:api_key] || ENV["MANDRILL_APIKEY"])
      end

      def opt_outs
        # @mandrill.rejects.list.map do |record|
        #   record
        # end
        []
      end

      def self.discoverable?
        !!(defined?(::Mandrill::API) && ENV["MANDRILL_APIKEY"])
      end

    end
  end
end
