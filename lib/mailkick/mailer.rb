module Mailkick
  module Mailer

    def self.included(base)
      base.class_eval do
        alias_method_chain :mail, :mailkick
      end
    end

    def mail_with_mailkick(headers = {}, &block)
      message = mail_without_mailkick(headers, &block)

      Mailkick::Processor.new(message).process

      message
    end

  end
end
