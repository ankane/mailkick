Rails.application.routes.draw do
  mount Mailkick::Engine => "/mailkick"
end

Mailkick::Engine.routes.draw do
  scope format: false do
    get '/subscriptions/*id/unsubscribe', to: "subscriptions#unsubscribe", as: :unsubscribe_subscription
    get '/subscriptions/*id/subscribe', to: "subscriptions#subscribe", as: :subscribe_subscription
    get '/subscriptions/*id', to: "subscriptions#show", as: :subscription
  end
end
