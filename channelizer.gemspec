# -*- encoding: utf-8 -*-
require File.expand_path('../lib/channelizer/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Paul Morton"]
  gem.email         = ["pmorton@biaprotect.com"]
  gem.description   = %q{A gem that abstracts shell and upload channels}
  gem.summary       = File.read('README.md')
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "channelizer"
  gem.require_paths = ["lib"]
  gem.version       = Channelizer::VERSION
  gem.add_runtime_dependency "winrm", "~> 1.1.2"
  gem.add_runtime_dependency "net-ssh", "~> 2.5.2"
  gem.add_runtime_dependency "net-scp", "~> 1.0.4"

end
