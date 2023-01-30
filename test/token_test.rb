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
    message = "BAhbCTBpBkkiCVVzZXIGOgZFRkkiCnNhbGVzBjsAVA==--2e62acf897286c15a8bce3bf71823551a7fb41d6"
    assert_equal [nil, 1, "User", "sales"], Mailkick.message_verifier.verify(message)
  end
end
