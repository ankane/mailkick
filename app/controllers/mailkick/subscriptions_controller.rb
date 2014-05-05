module Mailkick
  class SubscriptionsController < ActionController::Base
    before_filter :set_email

    def show
    end

    def unsubscribe
      Mailkick.opt_out(email: @email, user: @user, list: @list)
      redirect_to subscription_path(params[:id])
    end

    def subscribe
      Mailkick.opt_in(email: @email, user: @user, list: @list)
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
        @options = {}
        @options[:list] = @list if @list
      rescue ActiveSupport::MessageVerifier::InvalidSignature
        render text: "Subscription not found", status: :bad_request
      end
    end

    def opted_out?(options = {})
      Mailkick.opted_out?(@options.merge(options))
    end
    helper_method :opted_out?

    def subscribe_url(options = {})
      subscribe_subscription_path(params[:id], options)
    end
    helper_method :subscribe_url

    def unsubscribe_url(options = {})
      unsubscribe_subscription_path(params[:id], options)
    end
    helper_method :unsubscribe_url

  end
end
