module Mailkick
  module Model
    def has_subscriptions(prefix: false)
      prefix = prefix ? "mailkick_" : ""

      class_eval do
        has_many :mailkick_subscriptions, class_name: "Mailkick::Subscription", as: :subscriber
        scope "#{prefix}subscribed", ->(list) { joins(:mailkick_subscriptions).where(mailkick_subscriptions: {list: list}) }

        define_method("#{prefix}subscribe") do |list|
          mailkick_subscriptions.where(list: list).first_or_create!
          nil
        end

        define_method("#{prefix}unsubscribe") do |list|
          mailkick_subscriptions.where(list: list).delete_all
          nil
        end

        define_method("#{prefix}subscribed?") do |list|
          mailkick_subscriptions.where(list: list).exists?
        end
      end
    end
  end
end
