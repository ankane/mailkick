module Mailkick
  module UrlHelper
    def mailkick_unsubscribe_url(email: nil, list: nil, **options)
      email ||= controller.try(:message).try(:to).try(:first)

      raise ArgumentError, "Missing email" unless email

      Mailkick::Engine.routes.url_helpers.url_for(
        (ActionMailer::Base.default_url_options || {}).merge(options).merge(
          controller: "mailkick/subscriptions",
          action: "unsubscribe",
          id: Mailkick.generate_token(email, list: list)
        )
      )
    end
  end
end
