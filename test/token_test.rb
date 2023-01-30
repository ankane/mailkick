require_relative "test_helper"

class TokenTest < Minitest::Test
  def test_secret_token
    # ensure consistent across Rails releases
    expected = "8e83d93534a2cb212366bdb6ddcc753620489905f0c6cd27456a31f24d3f94b2e7fdba3b90ba82c9828d44883c94d1b77b2dd473092a2cdde825b31e3ef4552d"
    assert_equal expected, Mailkick.secret_token.unpack1("h*")
  end

  def test_message_verifier_v1
    message = "BAhbCTBpBkkiCVVzZXIGOgZFRkkiCnNhbGVzBjsAVA==--93b04b720fd4103e3826a3e7f02ff0c4b6b63a44"
    assert_equal [nil, 1, "User", "sales"], Mailkick.message_verifier.verify(message)
  end

  def test_message_verifier_v2
    message = "W251bGwsMSwiVXNlciIsInNhbGVzIl0=--68e6af4bc88e9910a912da36f779c349c4ac661d"
    assert_equal [nil, 1, "User", "sales"], Mailkick.message_verifier.verify(message)
  end

  def test_custom_token_v1
    with_secret_token("1" * 128) do
      message = "BAhbCTBpBkkiCVVzZXIGOgZFRkkiCnNhbGVzBjsAVA==--e37be0a9c71177dd4d2dcb078e8bf744bab5b955"
      assert_equal [nil, 1, "User", "sales"], Mailkick.message_verifier.verify(message)
    end
  end

  def test_custom_token_v2
    with_secret_token("1" * 128) do
      message = "W251bGwsMSwiVXNlciIsInNhbGVzIl0=--fb88c71ff1d08d86ffd05b19674c162588aad283"
      assert_equal [nil, 1, "User", "sales"], Mailkick.message_verifier.verify(message)
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
