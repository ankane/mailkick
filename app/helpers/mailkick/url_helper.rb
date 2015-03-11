module Mailkick
  module UrlHelper
    def mailkick_unsubscribe_url
      Mailkick::Engine.routes.url_helpers.url_for(
        (ActionMailer::Base.default_url_options || {}).merge(
          controller: "mailkick/subscriptions",
          action: "unsubscribe",
          id: "{{MAILKICK_TOKEN}}"
        )
      )
    end
  end
end
