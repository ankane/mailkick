require_relative "test_helper"

class MailkickTest < Minitest::Test
  def test_unsubscribe_url
    message = UserMailer.welcome.deliver_now
    html_body = message.html_part.body.to_s
    assert_equal "<p>BAhbCUkiFXRlc3RAZXhhbXBsZS5vcmcGOgZFVDAwMA%3D%3D--f435e91ba90e1732d3e999af1f2126dcc8182a5d</p>", html_body
    text_body = message.text_part.body.to_s
    assert_equal "Boom: BAhbCUkiFXRlc3RAZXhhbXBsZS5vcmcGOgZFVDAwMA%3D%3D--f435e91ba90e1732d3e999af1f2126dcc8182a5d", text_body
  end

  def test_opt_out
    Mailkick.opt_out(email: "test@example.org")
    assert_equal 1, Mailkick::OptOut.count
  end
end
