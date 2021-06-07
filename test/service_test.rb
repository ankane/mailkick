require_relative "test_helper"

class TestService < Mailkick::Service
  def opt_outs
    [{email: "test@example.com", time: Time.now}]
  end
end

class ServiceTest < Minitest::Test
  def setup
    Mailkick.services = [TestService.new]
  end

  def teardown
    Mailkick.services = []
  end

  def test_not_configured
    error = assert_raises do
      Mailkick.fetch_opt_outs
    end
    assert_equal "process_opt_outs_method not defined", error.message
  end
end
