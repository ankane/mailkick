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

      replace_parts(message.parts)
    end

    private

    def replace_parts(parts)
      parts.each do |part|
        if part.parts.any?
          replace_parts(part.parts)
        elsif part.content_type.match(/text\/(html|plain)/)
          part.body = part.body.decoded.gsub(/%7B%7BMAILKICK_TOKEN%7D%7D/) { mailkick_token }
        end
      end
    end

    def mailkick_token
      @mailkick_token ||= CGI.escape(Mailkick.generate_token(message.to.first, list: @list))
    end
  end
end
