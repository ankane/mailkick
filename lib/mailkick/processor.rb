module Mailkick
  class Processor
    attr_reader :message

    def initialize(message)
      @message = message
      @list = message[:mailkick_list].try(:value)
    end

    def process
      if @list
        # remove header
        message[:mailkick_list] = nil
      end

      parts = message.parts.any? ? message.parts : [message]
      parts.each do |part|
        if part.content_type.match(/text\/(html|plain)/)
          part.body = part.body.decoded.gsub(/%7B%7BMAILKICK_TOKEN%7D%7D/) { mailkick_token }
        end
      end
    end

    def mailkick_token
      @mailkick_token ||= begin
        email = message.to.first
        user = Mailkick.user_method.call(email) if Mailkick.user_method

        token = Mailkick.message_verifier.generate([email, user.try(:id), user.try(:class).try(:name), @list])
        CGI.escape(token)
      end
    end
  end
end
