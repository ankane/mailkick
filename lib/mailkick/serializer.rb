# need custom class due to
# https://github.com/rails/rails/issues/47185
module Mailkick
  class Serializer
    def self.dump(value)
      ActiveSupport::JSON.encode(value)
    end

    def self.load(value)
      ActiveSupport::JSON.decode(value)
    rescue JSON::ParserError
      Marshal.load(value)
    end
  end
end
