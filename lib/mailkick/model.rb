module Mailkick
  module Model
    def has_subscriptions
      class_eval do
        has_many :mailkick_subscriptions, class_name: "Mailkick::Subscription", as: :subscriber
        scope :mailkick_subscribed, ->(list) { joins(:mailkick_subscriptions).where(mailkick_subscriptions: {list:}) }
        scope :subscribed, ->(list) { mailkick_subscribed(list) } unless singleton_class.method_defined?(:subscribed)

        def mailkick_subscribe(list)
          mailkick_subscriptions.where(list:).first_or_create!
          nil
        end

        def mailkick_unsubscribe(list)
          mailkick_subscriptions.where(list:).delete_all
          nil
        end

        def mailkick_subscribed?(list)
          mailkick_subscriptions.where(list:).exists?
        end

        alias_method :subscribe, :mailkick_subscribe unless method_defined?(:subscribe)
        alias_method :unsubscribe, :mailkick_unsubscribe unless method_defined?(:unsubscribe)
        alias_method :subscribed?, :mailkick_subscribed? unless method_defined?(:subscribed?)

        alias_method :subscriptions, :mailkick_subscriptions unless method_defined?(:subscriptions)
      end
    end
  end
end
