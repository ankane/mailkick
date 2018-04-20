module Mailkick
  class Interceptor
    def self.delivering_email(message)
      Safely.safely do
        Mailkick::Processor.new(message).process
      end
    end
  end
end
