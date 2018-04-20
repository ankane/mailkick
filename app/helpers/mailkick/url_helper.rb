module Mailkick
  module UrlHelper
    def mailkick_unsubscribe_url
      @mailkick_unsubscribe_url ||= begin
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
end
