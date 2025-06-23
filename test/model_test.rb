require_relative "test_helper"

class ModelTest < Minitest::Test
  def test_works
    user = User.create!

    refute user.subscribed?("sales")
    assert_equal 0, User.subscribed("sales").count

    assert_nil user.subscribe("sales")

    assert user.subscribed?("sales")
    assert_equal 1, User.subscribed("sales").count

    assert_nil user.unsubscribe("sales")

    refute user.subscribed?("sales")
    assert_equal 0, User.subscribed("sales").count

    refute_respond_to User, :mailkick_subscribed
    refute_respond_to user, :mailkick_subscribe
    refute_respond_to user, :mailkick_unsubscribe
    refute_respond_to user, :mailkick_subscribed?
  end

  def test_prefix
    admin = Admin.create!

    refute admin.mailkick_subscribed?("sales")
    assert_equal 0, Admin.mailkick_subscribed("sales").count

    assert_nil admin.mailkick_subscribe("sales")

    assert admin.mailkick_subscribed?("sales")
    assert_equal 1, Admin.mailkick_subscribed("sales").count

    assert_nil admin.mailkick_unsubscribe("sales")

    refute admin.mailkick_subscribed?("sales")
    assert_equal 0, Admin.mailkick_subscribed("sales").count

    refute_respond_to Admin, :subscribed
    refute_respond_to admin, :subscribe
    refute_respond_to admin, :unsubscribe
    refute_respond_to admin, :subscribed?
  end
end
