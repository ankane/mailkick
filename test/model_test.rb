require_relative "test_helper"

class ModelTest < Minitest::Test
  def test_opted_out_class_methods
    company = Company.create!(name: "Test Company")
    email = "test@example.org"

    # Not opted out initially
    refute Mailkick.opted_out?(email: email, company_id: company.id, list: "marketing")

    # Opt out
    Mailkick.opt_out(email: email, company_id: company.id, list: "marketing")
    assert Mailkick.opted_out?(email: email, company_id: company.id, list: "marketing")

    # Opt back in
    Mailkick.opt_in(email: email, company_id: company.id, list: "marketing")
    refute Mailkick.opted_out?(email: email, company_id: company.id, list: "marketing")
  end

  def test_model_convenience_methods
    company = Company.create!(name: "Test Company")
    user = User.create!(email: "test@example.org")

    # Not opted out initially
    refute user.opted_out_of?(company_id: company.id, list: "marketing")

    # Opt out
    user.opt_out_of(company_id: company.id, list: "marketing")
    assert user.opted_out_of?(company_id: company.id, list: "marketing")

    # Opt back in
    user.opt_in_to(company_id: company.id, list: "marketing")
    refute user.opted_out_of?(company_id: company.id, list: "marketing")
  end

  def test_email_normalization
    company = Company.create!(name: "Test Company")
    email = "  TEST@Example.ORG  "

    Mailkick.opt_out(email: email, company_id: company.id, list: "marketing")

    # Should be found with normalized email
    assert Mailkick.opted_out?(email: "test@example.org", company_id: company.id, list: "marketing")
    assert Mailkick.opted_out?(email: "TEST@EXAMPLE.ORG", company_id: company.id, list: "marketing")
  end

  def test_default_list
    company = Company.create!(name: "Test Company")
    email = "test@example.org"

    # Default list is "marketing"
    Mailkick.opt_out(email: email, company_id: company.id)
    assert Mailkick.opted_out?(email: email, company_id: company.id)
    assert Mailkick.opted_out?(email: email, company_id: company.id, list: "marketing")
    refute Mailkick.opted_out?(email: email, company_id: company.id, list: "transactional")
  end

  def test_opt_outs_for_company
    company = Company.create!(name: "Test Company")

    Mailkick.opt_out(email: "user1@example.org", company_id: company.id, list: "marketing")
    Mailkick.opt_out(email: "user2@example.org", company_id: company.id, list: "marketing")
    Mailkick.opt_out(email: "user3@example.org", company_id: company.id, list: "transactional")

    all_opt_outs = Mailkick.opt_outs_for_company(company_id: company.id)
    assert_equal 3, all_opt_outs.count

    marketing_opt_outs = Mailkick.opt_outs_for_company(company_id: company.id, list: "marketing")
    assert_equal 2, marketing_opt_outs.count
  end

  def test_opt_outs_for_email
    company1 = Company.create!(name: "Company 1")
    company2 = Company.create!(name: "Company 2")
    email = "test@example.org"

    Mailkick.opt_out(email: email, company_id: company1.id, list: "marketing")
    Mailkick.opt_out(email: email, company_id: company2.id, list: "marketing")

    opt_outs = Mailkick.opt_outs_for_email(email: email)
    assert_equal 2, opt_outs.count
  end

  def test_argument_validation
    assert_raises(ArgumentError) { Mailkick.opted_out?(email: nil, company_id: 1) }
    assert_raises(ArgumentError) { Mailkick.opted_out?(email: "test@example.org", company_id: nil) }
    assert_raises(ArgumentError) { Mailkick.opt_out(email: nil, company_id: 1) }
    assert_raises(ArgumentError) { Mailkick.opt_out(email: "test@example.org", company_id: nil) }
  end

  def test_idempotent_opt_out
    company = Company.create!(name: "Test Company")
    email = "test@example.org"

    # Multiple opt-outs should not fail
    Mailkick.opt_out(email: email, company_id: company.id)
    Mailkick.opt_out(email: email, company_id: company.id)

    assert_equal 1, Mailkick::OptOut.count
  end
end
