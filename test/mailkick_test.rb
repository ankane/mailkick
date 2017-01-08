require_relative "test_helper"

class MailkickTest < Minitest::Test
  def test_unsubscribe_url
    message = UserMailer.welcome.deliver_now
    body = message.body.to_s
    assert_match "Boom", body
  end
end
