module Mailkick
  class Engine < ::Rails::Engine
    isolate_namespace Mailkick

    initializer "mailkick" do |app|
      Mailkick.discover_services
      secrets = app.respond_to?(:secrets) ? app.secrets : app.config
      Mailkick.secret_token = secrets.respond_to?(:secret_key_base) ? secrets.secret_key_base : secrets.secret_token
      ActiveSupport.on_load :action_mailer do
        helper Mailkick::UrlHelper
      end
    end
  end
end
