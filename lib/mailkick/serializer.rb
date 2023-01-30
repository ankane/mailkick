# need custom class due to
# https://github.com/rails/rails/issues/47185
module Mailkick
  class Serializer
    def self.dump(value)
      JSON.dump(value)
    end

    def self.load(value)
      JSON.load(value)
    rescue JSON::ParserError
      Marshal.load(value)
    end
  end
end
