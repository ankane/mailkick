module Mailkick
  class SubscriptionsController < ActionController::Base
    before_filter :set_email

    def show
    end

    def unsubscribe
      if subscribed?
        Mailkick::OptOut.create! do |o|
          o.email = @email
          o.user = @user
          o.reason = "unsubscribe"
        end
      end

      redirect_to subscription_path(params[:id])
    end

    def subscribe
      Mailkick::OptOut.where(email: @email, active: true).each do |opt_out|
        opt_out.active = false
        opt_out.save!
      end
      if @user and @user.respond_to?(:subscribe)
        @user.subscribe
      end

      redirect_to subscription_path(params[:id])
    end

    protected

    def set_email
      verifier = ActiveSupport::MessageVerifier.new(Mailkick.secret_token)
      begin
        @email, user_id, user_type = verifier.verify(params[:id])
        if user_type
          # on the unprobabilistic chance user_type is compromised, not much damage
          @user = user_type.constantize.find(user_id)
        end
      rescue ActiveSupport::MessageVerifier::InvalidSignature
        render text: "Subscription not found", status: :bad_request
      end
    end

    def subscribed?
      if @user and @user.respond_to?(:subscribed?)
        @user.subscribed?
      else
        Mailkick::OptOut.where(email: @email, active: true).empty?
      end
    end
    helper_method :subscribed?

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
