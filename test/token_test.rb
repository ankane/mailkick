require_relative "test_helper"

class TokenTest < Minitest::Test
  def test_secret_token
    # ensure consistent across Rails releases
    expected = "8e83d93534a2cb212366bdb6ddcc753620489905f0c6cd27456a31f24d3f94b2e7fdba3b90ba82c9828d44883c94d1b77b2dd473092a2cdde825b31e3ef4552d"
    assert_equal expected, Mailkick.secret_token.unpack1("h*")
  end
end
