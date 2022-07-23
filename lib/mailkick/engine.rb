module Mailkick
  class Engine < ::Rails::Engine
    isolate_namespace Mailkick

    initializer "mailkick" do |app|
      Mailkick.discover_services unless Mailkick.services.any?

      unless Mailkick.secret_token
        Mailkick.secret_token = app.key_generator.generate_key("mailkick")

        # TODO remove in 2.0
        creds =
          if app.respond_to?(:credentials) && app.credentials.secret_key_base
            app.credentials
          elsif app.respond_to?(:secrets)
            app.secrets
          else
            app.config
          end

        token = creds.respond_to?(:secret_key_base) ? creds.secret_key_base : creds.secret_token
        Mailkick.message_verifier.rotate(token)
      end
    end
  end
end
