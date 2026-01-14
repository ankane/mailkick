module Mailkick
  class OptOut < ActiveRecord::Base
    self.table_name = "mailkick_opt_outs"

    validates :email, presence: true
    validates :company_id, presence: true
    validates :list, presence: true
    validates :email, uniqueness: { scope: [:company_id, :list], message: "already opted out for this company and list" }

    scope :for_email, ->(email) { where(email: email.to_s.downcase) }
    scope :for_company, ->(company_id) { where(company_id: company_id) }
    scope :for_list, ->(list) { where(list: list) }

    before_validation :normalize_email

    private

    def normalize_email
      self.email = email.to_s.downcase.strip if email.present?
    end
  end
end
