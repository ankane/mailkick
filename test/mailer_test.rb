require_relative "test_helper"

class MailerTest < Minitest::Test
  def test_unsubscribe_url
    company = Company.create!(name: "Test Company")
    user = User.create!(email: "test@example.org")
    message = UserMailer.with(email: user.email, company_id: company.id).welcome.deliver_now
    html_body = message.html_part.body.to_s
    assert_includes html_body, "unsubscribe"
    assert_includes html_body, "opt_outs"
    text_body = message.text_part.body.to_s
    assert_includes text_body, "unsubscribe"
    assert_includes text_body, "opt_outs"
    assert_nil message["List-Unsubscribe-Post"]
    assert_nil message["List-Unsubscribe"]
  end

  def test_headers
    with_headers do
      company = Company.create!(name: "Test Company")
      user = User.create!(email: "test@example.org")
      message = UserMailer.with(email: user.email, company_id: company.id).welcome.deliver_now
      assert_equal "List-Unsubscribe=One-Click", message["List-Unsubscribe-Post"].to_s
      assert_includes message["List-Unsubscribe"].to_s, "unsubscribe"
      assert_includes message["List-Unsubscribe"].to_s, "opt_outs"
    end
  end

  def test_existing_header
    with_headers do
      company = Company.create!(name: "Test Company")
      user = User.create!(email: "test@example.org")
      message = UserMailer.with(email: user.email, company_id: company.id, header: true).welcome.deliver_now
      assert_nil message["List-Unsubscribe-Post"]
      assert_equal message["List-Unsubscribe"].to_s, "custom"
    end
  end
end
