module Mailkick
  class SubscriptionsController < ActionController::Base
    before_action :set_email

    def show
    end

    def unsubscribe
      Mailkick.opt_out(@options)
      redirect_to subscription_path(params[:id])
    end

    def subscribe
      Mailkick.opt_in(@options)
      redirect_to subscription_path(params[:id])
    end

    protected

    def set_email
      verifier = ActiveSupport::MessageVerifier.new(Mailkick.secret_token)
      begin
        @email, user_id, user_type, @list = verifier.verify(params[:id])
        if user_type
          # on the unprobabilistic chance user_type is compromised, not much damage
          @user = user_type.constantize.find(user_id)
        end
        @options = {
          email: @email,
          user: @user,
          list: @list
        }
      rescue ActiveSupport::MessageVerifier::InvalidSignature
        render text: "Subscription not found", status: :bad_request
      end
    end

    def opted_out?
      Mailkick.opted_out?(@options)
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
