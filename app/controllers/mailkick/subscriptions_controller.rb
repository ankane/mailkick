module Mailkick
  class SubscriptionsController < ActionController::Base
    protect_from_forgery with: :exception
    skip_forgery_protection only: [:unsubscribe]

    before_action :set_subscription

    def show
    end

    def unsubscribe
      subscription.delete_all

      if request.post? && params["List-Unsubscribe"] == "One-Click"
        # must not redirect according to RFC 8058
        # could render show action instead
        render plain: "Unsubscribe successful"
      else
        redirect_to subscription_path(params[:id])
      end
    end

    def subscribe
      subscription.first_or_create!

      redirect_to subscription_path(params[:id])
    end

    protected

    def set_subscription
      @email, @subscriber_id, @subscriber_type, @list = Mailkick.message_verifier.verify(params[:id])
    rescue ActiveSupport::MessageVerifier::InvalidSignature
      render plain: "Subscription not found", status: :bad_request
    end

    def subscription
      Mailkick::Subscription.where(
        subscriber_id: @subscriber_id,
        subscriber_type: @subscriber_type,
        list: @list
      )
    end

    def subscribed?
      subscription.exists?
    end
    helper_method :subscribed?

    def opted_out?
      !subscribed?
    end
    helper_method :opted_out?

    def subscribe_url
      subscribe_subscription_path(params[:id])
    end
    helper_method :subscribe_url

    def unsubscribe_url
      unsubscribe_subscription_path(params[:id])
    end
    helper_method :unsubscribe_url
  end
end
