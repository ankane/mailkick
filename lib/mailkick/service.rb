module Mailkick
  class Service
    def fetch_opt_outs
      Mailkick.process_opt_outs_method.call(opt_outs)
    end
  end
end
