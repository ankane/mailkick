require_relative "test_helper"

class ControllerTest < ActionDispatch::IntegrationTest
  def test_unsubscribe_url
    message = UserMailer.welcome.deliver_now
    text_body = message.text_part.body.to_s
    url = /Unsubscribe: (.+)/.match(text_body)[1]

    get url
    assert_response :redirect
    assert_equal 1, Mailkick::OptOut.count
  end

  def test_bad_signature
    message = UserMailer.welcome.deliver_now
    text_body = message.text_part.body.to_s
    url = /Unsubscribe: (.+)/.match(text_body)[1]

    get url.sub("/unsubscribe", "bad/unsubscribe")
    assert_response :bad_request
    assert_equal "Subscription not found", response.body
  end
end
