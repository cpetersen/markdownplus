# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'markdownplus/version'

Gem::Specification.new do |spec|
  spec.name          = "markdownplus"
  spec.version       = Markdownplus::VERSION
  spec.authors       = ["Christopher Petersen"]
  spec.email         = ["chris@petersen.io"]
  spec.description   = %q{Pre processors that allows the inclusion of external files and post processors for csn and json data.}
  spec.summary       = %q{Pre and post processors for markdown}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"

  spec.add_dependency "redcarpet"
  spec.add_dependency "pygments.rb"
end
