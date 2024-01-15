module Mailkick
  module UrlHelper
    def mailkick_unsubscribe_url(subscriber, list, **options)
      token = Mailkick.generate_token(subscriber, list)
      url = mailkick.unsubscribe_subscription_url(token, **options)
      if Mailkick.headers && headers["List-Unsubscribe"].nil?
        headers["List-Unsubscribe-Post"] ||= "List-Unsubscribe=One-Click"
        headers["List-Unsubscribe"] = "<#{url}>"
      end
      url
    end
  end
end
