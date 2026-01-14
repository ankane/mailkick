require_relative "test_helper"

class TokenTest < Minitest::Test
  def test_secret_token
    # ensure consistent across Rails releases
    expected = "8e83d93534a2cb212366bdb6ddcc753620489905f0c6cd27456a31f24d3f94b2e7fdba3b90ba82c9828d44883c94d1b77b2dd473092a2cdde825b31e3ef4552d"
    assert_equal expected, Mailkick.secret_token.unpack1("h*")
  end

  def test_key_generator_hash_digest_class
    # ensure Rails application key generator hash digest class unchanged
    assert_equal OpenSSL::Digest::SHA256, Rails.application.key_generator.instance_variable_get(:@key_generator).instance_variable_get(:@hash_digest_class)
  end

  def test_generate_and_verify_token
    email = "test@example.org"
    company_id = 123
    list = "marketing"

    token = Mailkick.generate_token(email, company_id, list)

    # Verify the token decodes correctly
    decoded = Mailkick.verify_token(token)
    assert_equal [email, company_id, list], decoded
  end

  def test_token_email_normalization
    # Emails should be normalized in tokens
    token = Mailkick.generate_token("  TEST@Example.ORG  ", 123, "marketing")
    decoded = Mailkick.verify_token(token)
    assert_equal "test@example.org", decoded[0]
  end

  def test_custom_secret_token
    with_secret_token("1" * 128) do
      email = "test@example.org"
      company_id = 1
      list = "sales"

      token = Mailkick.generate_token(email, company_id, list)
      decoded = Mailkick.verify_token(token)
      assert_equal [email, company_id, list], decoded
    end
  end

  def test_token_validation
    assert_raises(ArgumentError) { Mailkick.generate_token(nil, 123, "marketing") }
    assert_raises(ArgumentError) { Mailkick.generate_token("", 123, "marketing") }
    assert_raises(ArgumentError) { Mailkick.generate_token("test@example.org", nil, "marketing") }
    assert_raises(ArgumentError) { Mailkick.generate_token("test@example.org", 123, nil) }
    assert_raises(ArgumentError) { Mailkick.generate_token("test@example.org", 123, "") }
  end

  def test_invalid_token_verification
    assert_raises(ActiveSupport::MessageVerifier::InvalidSignature) do
      Mailkick.verify_token("invalid-token")
    end
  end

  private

  def with_secret_token(token)
    previous_token = Mailkick.secret_token
    previous_verifier = Mailkick.message_verifier
    begin
      Mailkick.secret_token = token
      yield
    ensure
      Mailkick.secret_token = previous_token
      Mailkick.message_verifier = previous_verifier
    end
  end
end
