require_relative "lib/mailkick/version"

Gem::Specification.new do |spec|
  spec.name          = "mailkick"
  spec.version       = Mailkick::VERSION
  spec.summary       = "Email unsubscribes for Rails"
  spec.homepage      = "https://github.com/ankane/mailkick"
  spec.license       = "MIT"

  spec.author        = "Andrew Kane"
  spec.email         = "andrew@ankane.org"

  spec.files         = Dir["*.{md,txt}", "{app,config,lib}/**/*"]
  spec.require_path  = "lib"

  spec.required_ruby_version = ">= 2.4"

  spec.add_dependency "activesupport", ">= 5"
end
