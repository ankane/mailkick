module Mailkick
  class SubscriptionsController < ActionController::Base
    before_filter :set_email

    def show
    end

    def unsubscribe
      if !opted_out?
        Mailkick::OptOut.create! do |o|
          o.email = @email
          o.user = @user
          o.reason = "unsubscribe"
          o.list = @list
        end
      end

      redirect_to subscription_path(params[:id])
    end

    def subscribe
      Mailkick::OptOut.where(email: @email, active: true).each do |opt_out|
        opt_out.active = false
        opt_out.save!
      end
      if @user and @user.respond_to?(:opt_in)
        @user.opt_in(@options)
      end

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
      options = @options.merge(options)
      if @user and @user.respond_to?(:opted_out?)
        @user.opted_out?(options)
      else
        relation = Mailkick::OptOut.where(email: @email, active: true)
        if options[:list]
          relation.where("list IS NULL OR list = ?", options[:list])
        else
          relation.where("list IS NULL")
        end.any?
      end
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
