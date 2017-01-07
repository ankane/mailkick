module Mailkick
  class Processor
    attr_reader :message

    def initialize(message)
      @message = message
    end

    def process
      email = message.to.first
      user = Mailkick.user_method.call(email) if Mailkick.user_method
      list = message[:mailkick_list].try(:value)
      if list
        # remove header
        message[:mailkick_list] = nil
      end

      verifier = ActiveSupport::MessageVerifier.new(Mailkick.secret_token)
      token = verifier.generate([email, user.try(:id), user.try(:class).try(:name), list])

      parts = message.parts.any? ? message.parts : [message]
      parts.each do |part|
        modified_raw_source = part.body.raw_source.gsub(/%7B%7BMAILKICK_TOKEN%7D%7D/, CGI.escape(token))
        part.body.instance_variable_set :@raw_source, modified_raw_source
      end
    end
  end
end
