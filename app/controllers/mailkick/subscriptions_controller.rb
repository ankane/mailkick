module Mailkick
  class SubscriptionsController < ActionController::Base
    protect_from_forgery with: :exception

    before_action :set_email

    def show
    end

    def unsubscribe
      subscription.delete_all

      Mailkick::Legacy.opt_out(legacy_options) if Mailkick::Legacy.opt_outs?

      redirect_to subscription_path(params[:id])
    end

    def subscribe
      subscription.first_or_create!

      Mailkick::Legacy.opt_in(legacy_options) if Mailkick::Legacy.opt_outs?

      redirect_to subscription_path(params[:id])
    end

    protected

    def set_email
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

    def legacy_options
      if @subscriber_type
        # on the unprobabilistic chance subscriber_type is compromised, not much damage
        user = @subscriber_type.constantize.find(@subscriber_id)
      end
      {
        email: @email,
        user: user,
        list: @list
      }
    end
  end
end
