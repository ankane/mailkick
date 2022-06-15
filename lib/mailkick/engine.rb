module Mailkick
  class Engine < ::Rails::Engine
    isolate_namespace Mailkick

    initializer "mailkick" do |app|
      Mailkick.discover_services unless Mailkick.services.any?

      Mailkick.message_verifier ||= app.message_verifier('mailkick')

      # Deprecated: look up secret_key_base
      Mailkick.secret_token ||= begin
        creds =
          if app.respond_to?(:credentials) && app.credentials.secret_key_base
            app.credentials
          elsif app.respond_to?(:secrets)
            app.secrets
          else
            app.config
          end

        creds.respond_to?(:secret_key_base) ? creds.secret_key_base : creds.secret_token
      end

      # Use deprecated secret to verify messages
      Mailkick.message_verifier.rotate Mailkick.secret_token
    end
  end
end
