module Mailkick
  module Mailer
    def mail(headers = {}, &block)
      message = super

      Mailkick::Processor.new(message).process

      message
    end
  end
end
