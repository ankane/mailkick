module Mailkick
  module UrlHelper
    def mailkick_unsubscribe_url(subscriber, list, **options)
      token = Mailkick.generate_token(subscriber, list)
      mailkick.unsubscribe_subscription_url(token, **options)
    end
  end
end
