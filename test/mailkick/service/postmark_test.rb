require "test_helper"

module Mailkick
  class PostmarkServiceTest < Minitest::Test
    class TestClient
      attr_accessor :bounces_to_return

      def bounces
        bounces_to_return
      end
    end

    # Stub Postmark module for testing
    module ::Postmark
      class ApiClient
        def initialize(api_key); end
      end
    end

    def setup
      @client = TestClient.new
      @service = Mailkick::Service::Postmark.new(api_key: "fake-key")
      @service.instance_variable_set(:@client, @client)
    end

    def test_opt_outs_for_permanent_failures
      bounces = [
        bounce_record("HardBounce", "hard@example.com"),
        bounce_record("BadEmailAddress", "bad@example.com"),
        bounce_record("Blocked", "blocked@example.com"),
        bounce_record("DMARCPolicy", "dmarc@example.com"),
        bounce_record("AddressChange", "changed@example.com")
      ]

      assert_opt_outs_for(bounces) do |opt_outs|
        assert_equal 5, opt_outs.size
        opt_outs.each { |opt_out| assert_equal "bounce", opt_out[:reason] }
      end
    end

    def test_opt_outs_for_user_actions
      bounces = [
        bounce_record("SpamNotification", "spam1@example.com"),
        bounce_record("SpamComplaint", "spam2@example.com"),
        bounce_record("Unsubscribe", "unsub@example.com"),
        bounce_record("ManuallyDeactivated", "deactivated@example.com")
      ]

      assert_opt_outs_for(bounces) do |opt_outs|
        assert_equal 4, opt_outs.size
        
        spam_outs = opt_outs.select { |o| o[:reason] == "spam" }
        assert_equal 2, spam_outs.size
        
        unsub_outs = opt_outs.select { |o| o[:reason] == "unsubscribe" }
        assert_equal 2, unsub_outs.size
      end
    end

    def test_ignores_temporary_failures
      bounces = [
        bounce_record("Transient", "temp@example.com"),
        bounce_record("SoftBounce", "soft@example.com"),
        bounce_record("AutoResponder", "auto@example.com"),
        bounce_record("DnsError", "dns@example.com")
      ]

      assert_opt_outs_for(bounces) do |opt_outs|
        assert_empty opt_outs
      end
    end

    private

    def bounce_record(type, email)
      {
        type: type,
        email: email,
        bounced_at: Time.now.utc.iso8601
      }
    end

    def assert_opt_outs_for(bounces)
      @client.bounces_to_return = bounces
      opt_outs = @service.opt_outs
      yield opt_outs
    end
  end
end 