require_relative "test_helper"

class MailkickTest < Minitest::Test
  def test_unsubscribe_url
    message = UserMailer.welcome.deliver_now
    html_body = message.html_part.body.to_s
    assert_includes html_body, "BAhbCUkiFXRlc3RAZXhhbXBsZS5vcmcGOgZFVDAwMA==--f435e91ba90e1732d3e999af1f2126dcc8182a5d"
    text_body = message.text_part.body.to_s
    assert_includes text_body, "BAhbCUkiFXRlc3RAZXhhbXBsZS5vcmcGOgZFVDAwMA==--f435e91ba90e1732d3e999af1f2126dcc8182a5d"
  end

  def test_opt_out
    email = "test2@example.org"
    user = User.create!(email: email)

    Mailkick.opt_out(email: email, user: user)

    opt_outs = Mailkick::OptOut.all.to_a
    assert_equal 1, opt_outs.size

    opt_out = opt_outs.first
    assert_equal email, opt_out.email
    assert_equal user, opt_out.user

    assert user.opted_out?
    assert_equal 1, User.opted_out.count
    assert_equal 0, User.not_opted_out.count
  end
end
