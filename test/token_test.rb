require_relative "test_helper"

class TokenTest < Minitest::Test
  def test_secret_token
    # ensure consistent across Rails releases
    expected = "5b0c752b9aa6c79e4a76a947f1fd7436f309959f48a978cadd1dec185a7db584b689b4ad1c7814f900f088b3c8859b99cc02542f3a4d6aa76c1951af453fe23a"
    assert_equal expected, Mailkick.secret_token.unpack1("h*")
  end
end
