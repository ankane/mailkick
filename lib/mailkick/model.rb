module Mailkick
  module Model
    def mailkick_user(opts = {})
      email_key = opts[:email_key] || :email
      class_eval do
        scope :opted_out, proc {|options = {}|
          opt_outs = Mailkick::OptOut.arel_table

          list = opt_outs[:list].eq(nil)
          list = list.or(opt_outs[:list].eq(options[:list])) if options[:list]

          user_id = arel_table[primary_key].eq(opt_outs[:user_id])
          user_type = opt_outs[:user_type].eq(name)
          user_condition = arel_table.grouping(user_id.and(user_type))
          email = arel_table[email_key].eq(opt_outs[:email])
          active = opt_outs[:active].eq(true)

          exists_condition = email.or(user_condition).and(active).and(list)
          exists_statement = opt_outs.project(Arel.star).where(exists_condition).exists
          exists_statement = exists_statement.not if options[:not]

          where(exists_statement)
        }
        scope :not_opted_out, proc {|options = {}|
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
