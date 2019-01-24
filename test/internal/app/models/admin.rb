class Admin < ActiveRecord::Base
  mailkick_user email_key: :email_address
end
