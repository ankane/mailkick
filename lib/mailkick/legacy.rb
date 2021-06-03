module Mailkick
  module Legacy
    # checks for table as long as it exists
    def self.opt_outs?
      unless defined?(@opt_outs) && @opt_outs == false
        @opt_outs = ActiveRecord::Base.connection.table_exists?("mailkick_opt_outs")
      end
      @opt_outs
    end

    def self.opted_out?(options)
      opt_outs(options).any?
    end

    def self.opt_out(options)
      unless opted_out?(options)
        time = options[:time] || Time.now
        Mailkick::OptOut.create! do |o|
          o.email = options[:email]
          o.user = options[:user]
          o.reason = options[:reason] || "unsubscribe"
          o.list = options[:list]
          o.created_at = time
          o.updated_at = time
        end
      end
      true
    end

    def self.opt_in(options)
      opt_outs(options).each do |opt_out|
        opt_out.active = false
        opt_out.save!
      end
      true
    end

    def self.opt_outs(options = {})
      relation = Mailkick::OptOut.where(active: true)

      contact_relation = Mailkick::OptOut.none
      if (email = options[:email])
        contact_relation = contact_relation.or(Mailkick::OptOut.where(email: email))
      end
      if (user = options[:user])
        contact_relation = contact_relation.or(
          Mailkick::OptOut.where("user_id = ? AND user_type = ?", user.id, user.class.name)
        )
      end
      relation = relation.merge(contact_relation) if email || user

      relation =
        if options[:list]
          relation.where("list IS NULL OR list = ?", options[:list])
        else
          relation.where("list IS NULL")
        end

      relation
    end

    def self.opted_out_emails(options = {})
      Set.new(opt_outs(options).where.not(email: nil).distinct.pluck(:email))
    end

    def self.opted_out_users(options = {})
      Set.new(opt_outs(options).where.not(user_id: nil).map(&:user))
    end
  end
end
