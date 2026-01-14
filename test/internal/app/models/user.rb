class User < ActiveRecord::Base
  has_email_opt_outs email_field: :email
end
