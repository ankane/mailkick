module Mailkick
  class Engine < ::Rails::Engine
    isolate_namespace Mailkick

    initializer "mailkick" do |app|
      Mailkick.discover_services
      Mailkick.secret_token = app.config.respond_to?(:secret_key_base) ? app.config.secret_key_base : app.config.secret_token
      ActiveSupport.on_load :action_mailer do
        helper Mailkick::UrlHelper
      end
    end
  end
end
