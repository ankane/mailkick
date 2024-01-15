require_relative "test_helper"

class ControllerTest < ActionDispatch::IntegrationTest
  def test_unsubscribe_url
    user = User.create!
    user.subscribe("sales")
    message = UserMailer.with(user: user).welcome.deliver_now
    text_body = message.text_part.body.to_s
    url = /Unsubscribe: (.+)/.match(text_body)[1]

    get url
    assert_response :redirect
    refute user.subscribed?("sales")
  end

  def test_unsubscribe_headers
    with_headers do
      user = User.create!
      user.subscribe("sales")
      message = UserMailer.with(user: user).welcome.deliver_now
      url = message["List-Unsubscribe"].to_s[1..-2]

      post url, params: {"List-Unsubscribe" => "One-Click"}
      assert_response :success
      assert_includes "Unsubscribe successful", response.body
      refute user.subscribed?("sales")
    end
  end

  def test_bad_signature
    user = User.create!
    message = UserMailer.with(user: user).welcome.deliver_now
    text_body = message.text_part.body.to_s
    url = /Unsubscribe: (.+)/.match(text_body)[1]

    get url.sub("/unsubscribe", "bad/unsubscribe")
    assert_response :bad_request
    assert_equal "Subscription not found", response.body
  end
end
