require_relative "test_helper"

class MailerTest < Minitest::Test
  def test_unsubscribe_url
    user = User.create!
    message = UserMailer.with(user: user).welcome.deliver_now
    html_body = message.html_part.body.to_s
    assert_includes html_body, "unsubscribe"
    text_body = message.text_part.body.to_s
    assert_includes text_body, "unsubscribe"
  end
end
