Rails.application.routes.draw do
  unless respond_to?(:has_named_route?) && has_named_route?("mailkick")
    mount Mailkick::Engine => "/mailkick" if Mailkick.mount
  end
end

Mailkick::Engine.routes.draw do
  resources :subscriptions, only: [:show] do
    match :unsubscribe, on: :member, via: [:get, :post]
    get :subscribe, on: :member
  end
end
