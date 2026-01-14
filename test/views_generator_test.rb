require_relative "test_helper"

require "generators/mailkick/views_generator"

class ViewsGeneratorTest < Rails::Generators::TestCase
  tests Mailkick::Generators::ViewsGenerator
  destination File.expand_path("../tmp", __dir__)
  setup :prepare_destination

  def test_works
    run_generator
    assert_file "app/views/mailkick/opt_outs/show.html.erb"
  end
end
