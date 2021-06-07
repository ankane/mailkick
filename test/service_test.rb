require_relative "test_helper"

class TestService < Mailkick::Service
  def opt_outs
    [{email: "test@example.com", time: Time.now}]
  end
end

class ServiceTest < Minitest::Test
  def setup
    super
    Mailkick.services = [TestService.new]
  end

  def teardown
    super
    Mailkick.services = []
  end

  def test_process_opt_outs
    user = User.create!(email: "test@example.com")
    user.subscribe("sales")

    previous_method = Mailkick.process_opt_outs_method
    begin
      Mailkick.process_opt_outs_method = lambda do |opt_outs|
        emails = opt_outs.map { |v| v[:email] }
        subscribers = User.includes(:mailkick_subscriptions).where(email: emails).index_by(&:email)

        opt_outs.each do |opt_out|
          subscriber = subscribers[opt_out[:email]]
          next unless subscriber

          subscriber.mailkick_subscriptions.each do |subscription|
            subscription.destroy if subscription.created_at < opt_out[:time]
          end
        end
      end
      Mailkick.fetch_opt_outs
      refute user.subscribed?("sales")
    ensure
      Mailkick.process_opt_outs_method = previous_method
    end
  end

  def test_not_configured
    error = assert_raises do
      Mailkick.fetch_opt_outs
    end
    assert_equal "process_opt_outs_method not defined", error.message
  end
end
