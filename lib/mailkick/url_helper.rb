module Mailkick
  module UrlHelper
    # Generate an unsubscribe URL for an email address
    #
    # @param email [String] the email address
    # @param company_id [Integer] the company ID
    # @param list [String] the mailing list (default: "marketing")
    # @param options [Hash] additional URL options (e.g., host)
    # @return [String] the unsubscribe URL
    def mailkick_unsubscribe_url(email, company_id, list = "marketing", **options)
      token = Mailkick.generate_token(email, company_id, list)
      url = mailkick.unsubscribe_opt_out_url(token, **options)
      if Mailkick.headers && headers["List-Unsubscribe"].nil?
        headers["List-Unsubscribe-Post"] ||= "List-Unsubscribe=One-Click"
        headers["List-Unsubscribe"] = "<#{url}>"
      end
      url
    end

    # Generate an opt-out management page URL
    #
    # @param email [String] the email address
    # @param company_id [Integer] the company ID
    # @param list [String] the mailing list (default: "marketing")
    # @param options [Hash] additional URL options (e.g., host)
    # @return [String] the opt-out page URL
    def mailkick_opt_out_url(email, company_id, list = "marketing", **options)
      token = Mailkick.generate_token(email, company_id, list)
      mailkick.opt_out_url(token, **options)
    end

    # Generate a subscribe (opt back in) URL
    #
    # @param email [String] the email address
    # @param company_id [Integer] the company ID
    # @param list [String] the mailing list (default: "marketing")
    # @param options [Hash] additional URL options (e.g., host)
    # @return [String] the subscribe URL
    def mailkick_subscribe_url(email, company_id, list = "marketing", **options)
      token = Mailkick.generate_token(email, company_id, list)
      mailkick.subscribe_opt_out_url(token, **options)
    end
  end
end
