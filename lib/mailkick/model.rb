module Mailkick
  module Model

    def mailkick_user(options = {})
      class_eval do
        scope :opted_out, proc {|options = {}|
          binds = [self.class.name, true]
          if options[:list]
            query = "(list IS NULL OR list = ?)"
            binds << options[:list]
          else
            query = "list IS NULL"
          end
          where("#{options[:not] ? "NOT " : ""}EXISTS(SELECT * FROM mailkick_opt_outs WHERE (#{table_name}.email = mailkick_opt_outs.email OR (#{table_name}.id = mailkick_opt_outs.user_id AND mailkick_opt_outs.user_type = ?)) AND active = ? AND #{query})", *binds)
        }
        scope :not_opted_out, proc {|options = {}|
          opted_out(options.merge(not: true))
        }

        def opt_outs(options = {})
          Mailkick.opt_outs({email: email, user: self}.merge(options))
        end

        def opted_out?(options = {})
          Mailkick.opted_out?({email: email, user: self}.merge(options))
        end

        def opt_out(options = {})
          Mailkick.opt_out({email: email, user: self}.merge(options))
        end

        def opt_in(options = {})
          Mailkick.opt_in({email: email, user: self}.merge(options))
        end

      end
    end

  end
end
