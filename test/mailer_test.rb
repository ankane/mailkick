require_relative "test_helper"

class MailerTest < Minitest::Test
  def test_unsubscribe_url
    user = User.create!
    message = UserMailer.with(user: user).welcome.deliver_now
    html_body = message.html_part.body.to_s
    assert_includes html_body, "unsubscribe"
    text_body = message.text_part.body.to_s
    assert_includes text_body, "unsubscribe"
    assert_nil message["List-Unsubscribe-Post"]
    assert_nil message["List-Unsubscribe"]
  end

  def test_headers
    with_headers do
      user = User.create!
      message = UserMailer.with(user: user).welcome.deliver_now
      assert_equal "List-Unsubscribe=One-Click", message["List-Unsubscribe-Post"].to_s
      assert_includes message["List-Unsubscribe"].to_s, "unsubscribe"
    end
  end

  def test_existing_header
    with_headers do
      user = User.create!
      message = UserMailer.with(user: user, header: true).welcome.deliver_now
      assert_nil message["List-Unsubscribe-Post"]
      assert_equal message["List-Unsubscribe"].to_s, "custom"
    end
  end
end
