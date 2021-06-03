module Mailkick
  class Subscription < ActiveRecord::Base
    self.table_name = "mailkick_subscriptions"

    belongs_to :subscriber, polymorphic: true

    validates :list, presence: true
  end
end
