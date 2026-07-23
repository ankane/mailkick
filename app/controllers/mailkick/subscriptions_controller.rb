module Mailkick
  class SubscriptionsController < ActionController::Base
    protect_from_forgery with: :exception
    skip_forgery_protection only: [:unsubscribe]

    before_action :set_subscription

    def show
    end

    def unsubscribe
      defer = request.get? && !params[:confirmed]

      subscription.delete_all unless defer

      if request.post? && params["List-Unsubscribe"] == "One-Click"
        # must not redirect according to RFC 8058
        # could render show action instead
        render plain: "Unsubscribe successful"
      elsif defer
        render :show
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

    def unsubscribing?
      action_name == "unsubscribe"
    end
    helper_method :unsubscribing?

    def subscribe_url
      subscribe_subscription_path(params[:id])
    end
    helper_method :subscribe_url

    # custom views created before 3.0 will use GET instead of POST
    # add confirmed parameter to ensure unsubscribed
    def unsubscribe_url
      unsubscribe_subscription_path(params[:id], {confirmed: true})
    end
    helper_method :unsubscribe_url

    def style_nonce
      if request.content_security_policy_nonce_directives&.include?("style-src")
        content_security_policy_nonce
      end
    end
    helper_method :style_nonce
  end
end
