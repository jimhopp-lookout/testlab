# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'testlab/version'

Gem::Specification.new do |gem|
  gem.name          = "testlab"
  gem.version       = TestLab::VERSION
  gem.authors       = ["Zachary Patten"]
  gem.email         = ["zachary@jovelabs.com"]
  gem.description   = %q{A framework for building virtual testing laboratories}
  gem.summary       = %q{A framework for building virtual testing laboratories}
  gem.homepage      = "https://github.com/zpatten"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
