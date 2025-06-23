class Admin < ActiveRecord::Base
  has_subscriptions prefix: true
end
