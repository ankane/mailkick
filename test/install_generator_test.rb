require_relative "test_helper"

require "generators/mailkick/install_generator"

class InstallGeneratorTest < Rails::Generators::TestCase
  tests Mailkick::Generators::InstallGenerator
  destination File.expand_path("../tmp", __dir__)
  setup :prepare_destination

  def test_works
    run_generator
    assert_migration "db/migrate/create_mailkick_opt_outs.rb", /create_table :mailkick_opt_outs do/
  end

  def test_primary_key_type
    with_generator_options({active_record: {primary_key_type: :uuid}}) do
      run_generator
    end
    assert_migration "db/migrate/create_mailkick_opt_outs.rb", /id: :uuid/
  end

  def test_columns
    run_generator
    assert_migration "db/migrate/create_mailkick_opt_outs.rb", /t.string :email, null: false/
    assert_migration "db/migrate/create_mailkick_opt_outs.rb", /t.bigint :company_id, null: false/
    assert_migration "db/migrate/create_mailkick_opt_outs.rb", /t.string :list, null: false, default: "marketing"/
  end

  def test_indexes
    run_generator
    assert_migration "db/migrate/create_mailkick_opt_outs.rb", /add_index :mailkick_opt_outs, \[:email, :company_id, :list\]/
    assert_migration "db/migrate/create_mailkick_opt_outs.rb", /add_index :mailkick_opt_outs, :company_id/
    assert_migration "db/migrate/create_mailkick_opt_outs.rb", /add_index :mailkick_opt_outs, :email/
  end

  private

  def with_generator_options(value)
    previous_value = Rails.configuration.generators.options
    begin
      Rails.configuration.generators.options = value
      yield
    ensure
      Rails.configuration.generators.options = previous_value
    end
  end
end
