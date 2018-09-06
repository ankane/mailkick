module Mailkick
  module Model
    def mailkick_user(opts = {})
      email_key = opts[:email_key] || :email
      class_eval do
        scope :opted_out, lambda { |options = {}|
          binds = [self.class.name, true]
          if options[:list]
            query = "(mailkick_opt_outs.list IS NULL OR mailkick_opt_outs.list = ?)"
            binds << options[:list]
          else
            query = "mailkick_opt_outs.list IS NULL"
          end
          where("#{options[:not] ? 'NOT ' : ''}EXISTS(SELECT * FROM mailkick_opt_outs WHERE (#{table_name}.#{email_key} = mailkick_opt_outs.email OR (#{table_name}.#{primary_key} = mailkick_opt_outs.user_id AND mailkick_opt_outs.user_type = ?)) AND mailkick_opt_outs.active = ? AND #{query})", *binds)
        }

        scope :not_opted_out, lambda { |options = {}|
          opted_out(options.merge(not: true))
        }

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
