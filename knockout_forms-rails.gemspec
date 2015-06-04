# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'knockout_forms/rails/version'

Gem::Specification.new do |spec|
  spec.name          = "knockout_forms-rails"
  spec.version       = KnockoutForms::Rails::VERSION
  spec.authors       = ["Santiago Palladino"]
  spec.email         = ["spalladino@manas.com.ar"]
  spec.summary       = %q{Knockout-js powered Rails form builder}
  spec.description   = %q{Provides a Rails form builder to seamlessly setup a Knockout-js based view model on your forms.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"

  spec.add_runtime_dependency "railties", [">= 3.1", "< 5"]
  spec.add_runtime_dependency "actionview", [">= 3", "< 5"]
end
