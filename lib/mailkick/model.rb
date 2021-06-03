module Mailkick
  module Model
    def has_subscriptions
      class_eval do
        has_many :mailkick_subscriptions, class_name: "Mailkick::Subscription", as: :subscriber
        scope :subscribed, -> (list) { joins(:mailkick_subscriptions).where(mailkick_subscriptions: {list: list}) }

        def subscribe(list)
          mailkick_subscriptions.where(list: list).first_or_create!
          nil
        end

        def unsubscribe(list)
          mailkick_subscriptions.where(list: list).delete_all
          nil
        end

        def subscribed?(list)
          mailkick_subscriptions.where(list: list).exists?
        end
      end
    end
  end
end
