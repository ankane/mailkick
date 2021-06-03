require_relative "test_helper"

class ModelTest < Minitest::Test
  def test_works
    user = User.create!

    refute user.subscribed?("sales")
    assert_equal 0, User.subscribed("sales").count

    user.subscribe("sales")

    assert user.subscribed?("sales")
    assert_equal 1, User.subscribed("sales").count

    user.unsubscribe("sales")

    refute user.subscribed?("sales")
    assert_equal 0, User.subscribed("sales").count
  end
end
