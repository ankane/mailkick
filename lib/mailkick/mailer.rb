module Mailkick
  module Mailer
    def mail(headers = {}, &block)
      message = super(headers, &block)

      Mailkick::Processor.new(message).process

      message
    end
  end
end
