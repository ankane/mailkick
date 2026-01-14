require_relative "test_helper"

class TestService < Mailkick::Service
  def opt_outs
    [
      {email: "test@example.com", time: Time.current, reason: "bounce"},
      {email: "test2@example.com", time: 1.day.ago, reason: "spam"}
    ]
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
    company = Company.create!(name: "Test Company")

    previous_method = Mailkick.process_opt_outs_method
    begin
      # Example of how process_opt_outs_method can be used to auto-opt-out
      # users who bounce or report spam
      Mailkick.process_opt_outs_method = lambda do |opt_outs|
        opt_outs.each do |opt_out|
          # Opt out the email from all companies for marketing emails
          # This is just an example - you might want different behavior
          Company.find_each do |company|
            Mailkick.opt_out(
              email: opt_out[:email],
              company_id: company.id,
              list: "marketing"
            )
          end
        end
      end

      assert_nil Mailkick.fetch_opt_outs

      # Both emails should now be opted out
      assert Mailkick.opted_out?(email: "test@example.com", company_id: company.id, list: "marketing")
      assert Mailkick.opted_out?(email: "test2@example.com", company_id: company.id, list: "marketing")
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
