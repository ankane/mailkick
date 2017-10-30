module Mailkick
  class OptOut < ActiveRecord::Base
    self.table_name = "mailkick_opt_outs"

    belongs_to :user, ActiveRecord::VERSION::MAJOR >= 5 ? {polymorphic: true, optional: true} : {polymorphic: true}
  end
end
