module Mailkick
  module UrlHelper
    def mailkick_unsubscribe_url(email: nil, list: nil)
      email ||= controller.message.to.first
      Mailkick::Engine.routes.url_helpers.url_for(
        (ActionMailer::Base.default_url_options || {}).merge(
          controller: "mailkick/subscriptions",
          action: "unsubscribe",
          id: Mailkick.generate_token(email, list: list)
        )
      )
    end
  end
end
