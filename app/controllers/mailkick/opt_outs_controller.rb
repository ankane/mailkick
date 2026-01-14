module Mailkick
  class OptOutsController < ActionController::Base
    protect_from_forgery with: :exception
    skip_forgery_protection only: [:unsubscribe]

    before_action :set_opt_out_params

    def show
    end

    def unsubscribe
      Mailkick.opt_out(email: @email, company_id: @company_id, list: @list)

      if request.post? && params["List-Unsubscribe"] == "One-Click"
        # must not redirect according to RFC 8058
        render plain: "Unsubscribe successful"
      else
        redirect_to opt_out_path(params[:id])
      end
    end

    def subscribe
      Mailkick.opt_in(email: @email, company_id: @company_id, list: @list)

      redirect_to opt_out_path(params[:id])
    end

    protected

    def set_opt_out_params
      @email, @company_id, @list = Mailkick.verify_token(params[:id])
    rescue ActiveSupport::MessageVerifier::InvalidSignature
      render plain: "Invalid or expired link", status: :bad_request
    end

    def opted_out?
      Mailkick.opted_out?(email: @email, company_id: @company_id, list: @list)
    end
    helper_method :opted_out?

    def subscribed?
      !opted_out?
    end
    helper_method :subscribed?

    def subscribe_url
      subscribe_opt_out_path(params[:id])
    end
    helper_method :subscribe_url

    def unsubscribe_url
      unsubscribe_opt_out_path(params[:id])
    end
    helper_method :unsubscribe_url

    def email
      @email
    end
    helper_method :email

    def list
      @list
    end
    helper_method :list
  end
end
