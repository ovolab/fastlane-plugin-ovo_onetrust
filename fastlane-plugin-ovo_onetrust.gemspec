lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fastlane/plugin/ovo_onetrust/version'

Gem::Specification.new do |spec|
  spec.name          = 'fastlane-plugin-ovo_onetrust'
  spec.version       = Fastlane::OvoOnetrust::VERSION
  spec.author        = 'Christian Borsato'
  spec.email         = 'christian@ovolab.com'

  spec.summary       = 'Fastlane plugin to upload mobile app builds to OneTrust and trigger automated SDK scanning.'
  spec.homepage      = "https://github.com/ovolab/fastlane-plugin-ovo_onetrust"
  spec.license       = "MIT"

  spec.files         = Dir["lib/**/*"] + %w(README.md LICENSE)
  spec.require_paths = ['lib']
  spec.metadata['rubygems_mfa_required'] = 'true'
  spec.required_ruby_version = '>= 3.0.0'

  spec.add_runtime_dependency 'rest-client'
end
