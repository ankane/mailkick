require_relative "test_helper"

class ControllerTest < ActionDispatch::IntegrationTest
  def test_unsubscribe_url
    company = Company.create!(name: "Test Company")
    user = User.create!(email: "test@example.org")

    # User is NOT opted out initially
    refute Mailkick.opted_out?(email: user.email, company_id: company.id, list: "marketing")

    message = UserMailer.with(email: user.email, company_id: company.id).welcome.deliver_now
    text_body = message.text_part.body.to_s
    url = /Unsubscribe: (.+)/.match(text_body)[1]

    # Click unsubscribe link
    get url
    assert_response :redirect

    # Now user IS opted out
    assert Mailkick.opted_out?(email: user.email, company_id: company.id, list: "marketing")
  end

  def test_unsubscribe_headers
    with_headers do
      company = Company.create!(name: "Test Company")
      user = User.create!(email: "test@example.org")

      message = UserMailer.with(email: user.email, company_id: company.id).welcome.deliver_now
      url = message["List-Unsubscribe"].to_s[1..-2]

      # RFC 8058 One-Click unsubscribe
      post url, params: {"List-Unsubscribe" => "One-Click"}
      assert_response :success
      assert_includes "Unsubscribe successful", response.body
      assert Mailkick.opted_out?(email: user.email, company_id: company.id, list: "marketing")
    end
  end

  def test_resubscribe
    company = Company.create!(name: "Test Company")
    user = User.create!(email: "test@example.org")

    # Opt out first
    Mailkick.opt_out(email: user.email, company_id: company.id, list: "marketing")
    assert Mailkick.opted_out?(email: user.email, company_id: company.id, list: "marketing")

    # Generate subscribe URL
    token = Mailkick.generate_token(user.email, company.id, "marketing")

    # Click subscribe link
    get "/mailkick/opt_outs/#{token}/subscribe"
    assert_response :redirect

    # Now user is NOT opted out
    refute Mailkick.opted_out?(email: user.email, company_id: company.id, list: "marketing")
  end

  def test_bad_signature
    company = Company.create!(name: "Test Company")
    user = User.create!(email: "test@example.org")
    message = UserMailer.with(email: user.email, company_id: company.id).welcome.deliver_now
    text_body = message.text_part.body.to_s
    url = /Unsubscribe: (.+)/.match(text_body)[1]

    get url.sub("/unsubscribe", "bad/unsubscribe")
    assert_response :bad_request
    assert_equal "Invalid or expired link", response.body
  end

  def test_company_isolation
    company1 = Company.create!(name: "Company 1")
    company2 = Company.create!(name: "Company 2")
    user = User.create!(email: "test@example.org")

    # Opt out from company 1
    Mailkick.opt_out(email: user.email, company_id: company1.id, list: "marketing")

    # Opted out for company 1
    assert Mailkick.opted_out?(email: user.email, company_id: company1.id, list: "marketing")
    # NOT opted out for company 2
    refute Mailkick.opted_out?(email: user.email, company_id: company2.id, list: "marketing")
  end

  def test_list_isolation
    company = Company.create!(name: "Test Company")
    user = User.create!(email: "test@example.org")

    # Opt out from marketing list
    Mailkick.opt_out(email: user.email, company_id: company.id, list: "marketing")

    # Opted out for marketing
    assert Mailkick.opted_out?(email: user.email, company_id: company.id, list: "marketing")
    # NOT opted out for transactional
    refute Mailkick.opted_out?(email: user.email, company_id: company.id, list: "transactional")
  end
end
