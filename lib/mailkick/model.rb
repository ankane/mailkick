module Mailkick
  module Model
    # Add opt-out checking methods to a model
    #
    # This is optional - you can also use Mailkick.opted_out? directly.
    # Use this if you want convenience methods on your model.
    #
    # @example
    #   class User < ApplicationRecord
    #     has_email_opt_outs email_field: :email
    #   end
    #
    #   user.opted_out_of?(company_id: 123, list: "marketing")
    #   user.opt_out_of(company_id: 123, list: "marketing")
    #   user.opt_in_to(company_id: 123, list: "marketing")
    #
    # @param email_field [Symbol] the name of the email attribute on the model (default: :email)
    def has_email_opt_outs(email_field: :email)
      class_eval do
        define_method(:opted_out_of?) do |company_id:, list: "marketing"|
          email_value = send(email_field)
          return false unless email_value.present?

          Mailkick.opted_out?(email: email_value, company_id: company_id, list: list)
        end

        define_method(:opt_out_of) do |company_id:, list: "marketing"|
          email_value = send(email_field)
          raise ArgumentError, "Email is blank" unless email_value.present?

          Mailkick.opt_out(email: email_value, company_id: company_id, list: list)
        end

        define_method(:opt_in_to) do |company_id:, list: "marketing"|
          email_value = send(email_field)
          raise ArgumentError, "Email is blank" unless email_value.present?

          Mailkick.opt_in(email: email_value, company_id: company_id, list: list)
        end

        define_method(:opt_outs_for_company) do |company_id:, list: nil|
          email_value = send(email_field)
          return Mailkick::OptOut.none unless email_value.present?

          scope = Mailkick::OptOut.for_email(email_value).for_company(company_id)
          scope = scope.for_list(list) if list.present?
          scope
        end
      end
    end

    # Legacy alias for backward compatibility
    # @deprecated Use has_email_opt_outs instead
    def has_subscriptions(prefix: false)
      warn "[DEPRECATION] `has_subscriptions` is deprecated. Use `has_email_opt_outs` instead. " \
           "Note: The opt-out model has changed from subscription-first to opt-out-only tracking."
      # Do nothing - old subscription behavior is not supported
    end
  end
end
