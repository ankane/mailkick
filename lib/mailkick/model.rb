module Mailkick
  module Model

    def mailkick_user(options = {})
      class_eval do
        scope :subscribed, proc{ joins(sanitize_sql_array(["LEFT JOIN mailkick_opt_outs ON #{table_name}.email = mailkick_opt_outs.email OR (#{table_name}.id = mailkick_opt_outs.user_id AND mailkick_opt_outs.user_type = ?)", name])).where("active != ?", true).uniq }

        def opt_outs
          Mailkick::OptOut.where("email = ? OR (user_id = ? AND user_type = ?)", email, id, self.class.name)
        end

        def subscribed?
          opt_outs.where(active: true).empty?
        end

        def subscribe
          opt_outs.where(active: true).each do |opt_out|
            opt_out.active = false
            opt_out.save!
          end
          true
        end

        def unsubscribe
          if subscribed?
            OptOut.create! do |o|
              o.email = email
              o.user = self
              o.reason = "unsubscribe"
              o.save!
            end
          end
          true
        end

      end
    end

  end
end
