module Mailkick
  class Engine < ::Rails::Engine
    isolate_namespace Mailkick

    initializer "mailkick" do |app|
      Mailkick.discover_services unless Mailkick.services.any?

      Mailkick.secret_token ||= app.key_generator.generate_key("mailkick")
    end
  end
end
