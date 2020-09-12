require_relative "test_helper"

class MailkickTest < Minitest::Test
  def setup
    User.delete_all
    Mailkick::OptOut.delete_all
  end

  def test_unsubscribe_url
    message = UserMailer.welcome.deliver_now
    html_body = message.html_part.body.to_s
    assert_includes html_body, "unsubscribe"
    text_body = message.text_part.body.to_s
    assert_includes text_body, "unsubscribe"
  end

  def test_opt_out
    email = "test2@example.org"
    user = User.create!(email: email)

    Mailkick.opt_out(email: email, user: user)

    opt_outs = Mailkick::OptOut.all.to_a
    assert_equal 1, opt_outs.size

    opt_out = opt_outs.first
    assert_equal email, opt_out.email
    assert_equal user, opt_out.user

    assert user.opted_out?
    assert_equal 1, User.opted_out.count
    assert_equal 0, User.not_opted_out.count
  end

  def test_opt_outs
    user1 = User.create!(email: 'user1@example.org')
    user2 = User.create!(email: 'user2@example.org')
    user3 = User.create!(email: 'user3@example.org')
    user4 = User.create!(email: 'user4@example.org')

    Mailkick.opt_out(email: user1.email, user: user1)
    Mailkick.opt_out(email: 'other2@example.org', user: user2)
    Mailkick.opt_out(email: 'other3@example.org')
    Mailkick.opt_out(user: user3)

    opt_outs = Mailkick.opt_outs
    assert_equal 4, opt_outs.size

    opt_outs = Mailkick.opt_outs(email: user1.email)
    assert_equal 1, opt_outs.size

    opt_outs = Mailkick.opt_outs(email: user2.email)
    assert_equal 0, opt_outs.size

    opt_outs = Mailkick.opt_outs(email: 'other2@example.org')
    assert_equal 1, opt_outs.size

    opt_outs = Mailkick.opt_outs(user: user2)
    assert_equal 1, opt_outs.size

    opt_outs = Mailkick.opt_outs(email: user2.email, user: user2)
    assert_equal 1, opt_outs.size

    opt_outs = Mailkick.opt_outs(email: 'other3@example.org', user: user2)
    assert_equal 2, opt_outs.size

    opt_outs = Mailkick.opt_outs(user: user3)
    assert_equal 1, opt_outs.size

    opt_outs = Mailkick.opt_outs(email: 'other4@example.org')
    assert_equal 0, opt_outs.size

    opt_outs = Mailkick.opt_outs(user: user4)
    assert_equal 0, opt_outs.size
  end

  def test_user_opted_out_scope
    user = User.create!
    user.opt_out
    assert_equal 1, User.opted_out.count
  end

  def test_user_not_opted_out
    User.create!
    assert_equal 1, User.not_opted_out.count
  end

  def test_instance_methods
    email = "test2@example.org"
    user = User.create!(email: email)
    user.opt_out
    assert user.opted_out?
    assert Mailkick::OptOut.exists?(email: email)
    user.opt_in
    assert !user.opted_out?
  end

  def test_email_key
    email = "test2@example.org"
    user = Admin.create!(email_address: email)
    user.opt_out
    assert user.opted_out?
    assert Mailkick::OptOut.exists?(email: email)
    user.opt_in
    assert !user.opted_out?
  end
end
