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
          relation = Mailkick::OptOut.where("email = ? OR (user_id = ? AND user_type = ?)", email, id, self.class.name)
          if options[:list]
            relation.where("list IS NULL OR list = ?", options[:list])
          else
            relation.where(list: nil)
          end
        end

        def opted_out?(options = {})
          opt_outs(options).where(active: true).any?
        end

        def opt_out(options = {})
          if !opted_out?(options)
            OptOut.create! do |o|
              o.email = email
              o.user = self
              o.reason = "unsubscribe"
              o.list = options[:list]
              o.save!
            end
          end
          true
        end

        def opt_in(options = {})
          opt_outs(options).where(active: true).each do |opt_out|
            opt_out.active = false
            opt_out.save!
          end
          true
        end

      end
    end

  end
end
