
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "mailkick/version"

Gem::Specification.new do |spec|
  spec.name          = "mailkick"
  spec.version       = Mailkick::VERSION
  spec.summary       = "Email subscriptions made easy"
  spec.homepage      = "https://github.com/ankane/mailkick"
  spec.license       = "MIT"

  spec.author        = "Andrew Kane"
  spec.email         = "andrew@chartkick.com"

  spec.files         = Dir["*.{md,txt}", "{app,config,lib}/**/*"]
  spec.require_path  = "lib"

  spec.required_ruby_version = ">= 2.2"

  spec.add_dependency "activesupport", ">= 4.2"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "gibbon", ">= 2"
  spec.add_development_dependency "mailgun-ruby"
  spec.add_development_dependency "mandrill-api"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "sendgrid_toolkit"
  spec.add_development_dependency "combustion"
  spec.add_development_dependency "rails"
  spec.add_development_dependency "sqlite3"
end
